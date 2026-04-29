import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_result.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';

String _defaultBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (override.isNotEmpty) return override;
  if (kIsWeb) return 'http://localhost:8000';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  } catch (_) {}
  return 'http://localhost:8000';
}

/// HTTP client with JWT interceptor + 401 refresh-once retry.
class ApiClient {
  final Dio dio;
  final TokenStorage _tokens;

  /// Optional hook: called when a refresh attempt fails — the caller can
  /// clear its session state (e.g. AuthProvider.logout()).
  void Function()? onAuthExpired;

  bool _refreshing = false;
  Completer<void>? _refreshCompleter;

  ApiClient(this._tokens, {String? baseUrl})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? _defaultBaseUrl(),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          contentType: 'application/json',
        )) {
    dio.interceptors.add(_authInterceptor());
  }

  InterceptorsWrapper _authInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip attaching tokens for auth endpoints.
          if (!_isAuthPath(options.path)) {
            final t = await _tokens.readAccess();
            if (t != null) {
              options.headers['Authorization'] = 'Bearer $t';
            }
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final resp = err.response;
          if (resp?.statusCode == 401 &&
              err.requestOptions.extra['_retry'] != true &&
              !_isAuthPath(err.requestOptions.path)) {
            try {
              await _refresh();
              final retried = await _retry(err.requestOptions);
              return handler.resolve(retried);
            } catch (_) {
              onAuthExpired?.call();
              return handler.next(err);
            }
          }
          handler.next(err);
        },
      );

  bool _isAuthPath(String path) =>
      path.startsWith('/auth/login') ||
      path.startsWith('/auth/signup') ||
      path.startsWith('/auth/refresh');

  Future<void> _refresh() async {
    if (_refreshing) {
      await _refreshCompleter?.future;
      return;
    }
    _refreshing = true;
    _refreshCompleter = Completer<void>();
    try {
      final refresh = await _tokens.readRefresh();
      if (refresh == null) throw Exception('No refresh token');
      final resp = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refresh},
        options: Options(headers: {'Authorization': null}),
      );
      final newAccess = resp.data['access_token'] as String;
      final newRefresh = resp.data['refresh_token'] as String;
      final uid = await _tokens.readUserId() ?? '';
      await _tokens.writeTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
        userId: uid,
      );
      _refreshCompleter?.complete();
    } catch (e) {
      _refreshCompleter?.completeError(e);
      rethrow;
    } finally {
      _refreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions opts) async {
    final access = await _tokens.readAccess();
    final newOpts = Options(
      method: opts.method,
      headers: {...opts.headers, 'Authorization': 'Bearer $access'},
      contentType: opts.contentType,
      responseType: opts.responseType,
    );
    return dio.request<dynamic>(
      opts.path,
      data: opts.data,
      queryParameters: opts.queryParameters,
      options: newOpts.copyWith(extra: {'_retry': true}),
    );
  }

  ApiError mapError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const ApiError(
          kind: ApiErrorKind.offline,
          message: 'Could not reach the server',
        );
      }
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map
          ? (e.response?.data as Map)['detail']?.toString()
          : null;
      final msg = detail ?? e.message ?? 'Request failed';
      switch (status) {
        case 401:
          return ApiError(
            kind: ApiErrorKind.unauthorized,
            message: msg,
            statusCode: status,
          );
        case 404:
          return ApiError(
            kind: ApiErrorKind.notFound,
            message: msg,
            statusCode: status,
          );
        case 409:
          return ApiError(
            kind: ApiErrorKind.conflict,
            message: msg,
            statusCode: status,
          );
        default:
          return ApiError(
            kind: ApiErrorKind.server,
            message: msg,
            statusCode: status,
          );
      }
    }
    return ApiError(kind: ApiErrorKind.unknown, message: e.toString());
  }

  /// Unwrap a call into [ApiResult]. Handlers throw on non-2xx.
  Future<ApiResult<T>> call<T>(Future<T> Function() fn) async {
    try {
      return Ok(await fn());
    } catch (e) {
      return Err(mapError(e));
    }
  }

  Never throwFrom(Object e) => throw ApiException(mapError(e));
}

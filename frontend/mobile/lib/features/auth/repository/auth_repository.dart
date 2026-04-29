import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/models/user.dart';
import '../../../core/storage/secure_storage.dart';

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _tokens;

  AuthRepository(this._api, this._tokens);

  Future<AppUser> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final Response resp = await _api.dio.post(
      Endpoints.authSignup,
      data: {
        'email': email,
        'password': password,
        'display_name': ?displayName,
      },
    );
    return _persist(resp.data as Map<String, dynamic>);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final resp = await _api.dio.post(
      Endpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    return _persist(resp.data as Map<String, dynamic>);
  }

  Future<AppUser> me() async {
    final resp = await _api.dio.get(Endpoints.authMe);
    return AppUser.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final refresh = await _tokens.readRefresh();
    try {
      if (refresh != null) {
        await _api.dio.post(Endpoints.authLogout, data: {'refresh_token': refresh});
      }
    } catch (_) {
      // Ignore; we still clear local state.
    } finally {
      await _tokens.clear();
    }
  }

  Future<AppUser> _persist(Map<String, dynamic> body) async {
    final user = AppUser.fromJson(body['user'] as Map<String, dynamic>);
    await _tokens.writeTokens(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String,
      userId: user.id,
    );
    return user;
  }
}

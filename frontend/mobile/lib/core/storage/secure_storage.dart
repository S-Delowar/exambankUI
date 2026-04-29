import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUserId = 'user_id';

  final FlutterSecureStorage _s;

  TokenStorage({FlutterSecureStorage? storage})
      : _s = storage ?? const FlutterSecureStorage();

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await Future.wait([
      _s.write(key: _kAccess, value: accessToken),
      _s.write(key: _kRefresh, value: refreshToken),
      _s.write(key: _kUserId, value: userId),
    ]);
  }

  Future<String?> readAccess() => _s.read(key: _kAccess);
  Future<String?> readRefresh() => _s.read(key: _kRefresh);
  Future<String?> readUserId() => _s.read(key: _kUserId);

  Future<void> clear() async {
    await Future.wait([
      _s.delete(key: _kAccess),
      _s.delete(key: _kRefresh),
      _s.delete(key: _kUserId),
    ]);
  }

  Future<void> writeAccessOnly(String access) => _s.write(key: _kAccess, value: access);
}

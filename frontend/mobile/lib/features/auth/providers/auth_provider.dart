import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/db/local_database.dart';
import '../../../core/models/user.dart';
import '../../../core/storage/secure_storage.dart';
import '../repository/auth_repository.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  final TokenStorage _tokens;
  final ApiClient _api;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  String? _error;
  bool _busy = false;

  AuthProvider(this._repo, this._tokens, this._api) {
    _api.onAuthExpired = () {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
    };
  }

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get error => _error;
  bool get busy => _busy;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> bootstrap() async {
    final access = await _tokens.readAccess();
    if (access == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _user = await _repo.me();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _tokens.clear();
      _status = AuthStatus.unauthenticated;
      _user = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = _api.mapError(e).message;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String email, String password, {String? displayName}) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.signup(
        email: email,
        password: password,
        displayName: displayName,
      );
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = _api.mapError(e).message;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    try {
      await LocalDatabase.instance.clearUserScopedTables();
    } catch (_) {}
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kThemeMode = 'theme_mode';
  static const _kLastSync = 'last_sync_at_ms';

  final SharedPreferences _p;
  AppPrefs(this._p);

  static Future<AppPrefs> load() async =>
      AppPrefs(await SharedPreferences.getInstance());

  String get themeMode => _p.getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String v) => _p.setString(_kThemeMode, v);

  DateTime? get lastSync {
    final ms = _p.getInt(_kLastSync);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastSync(DateTime t) =>
      _p.setInt(_kLastSync, t.millisecondsSinceEpoch);
}

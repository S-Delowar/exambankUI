import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _c;
  StreamSubscription? _sub;
  bool _online = true;

  ConnectivityProvider({Connectivity? connectivity})
      : _c = connectivity ?? Connectivity();

  bool get isOnline => _online;

  Future<void> bootstrap() async {
    final r = await _c.checkConnectivity();
    _apply(r);
    _sub = _c.onConnectivityChanged.listen(_apply);
  }

  void _apply(List<ConnectivityResult> r) {
    final wasOnline = _online;
    _online = r.any((e) =>
        e == ConnectivityResult.wifi ||
        e == ConnectivityResult.mobile ||
        e == ConnectivityResult.ethernet ||
        e == ConnectivityResult.vpn);
    if (_online != wasOnline) notifyListeners();
    if (!wasOnline && _online) {
      _onReconnect?.call();
    }
  }

  void Function()? _onReconnect;
  set onReconnect(void Function() cb) => _onReconnect = cb;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

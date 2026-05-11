import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity and exposes a stream + sync check.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  late final StreamController<bool> _controller;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isOnline = true;

  ConnectivityService() {
    _controller = StreamController<bool>.broadcast();
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(_isOnline);
      }
    });

    // Check initial state
    _connectivity.checkConnectivity().then((results) {
      _isOnline = !results.contains(ConnectivityResult.none);
      _controller.add(_isOnline);
    });
  }

  /// Whether the device currently has a network connection.
  bool get isOnline => _isOnline;

  /// Stream that emits `true` when online, `false` when offline.
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}

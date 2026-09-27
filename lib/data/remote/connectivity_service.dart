import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Online / offline detection. Any failure is treated as offline so the app
/// never waits on the network.
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity]) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<bool> isOnline() async {
    try {
      return _online(await _connectivity.checkConnectivity());
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get changes => _connectivity.onConnectivityChanged.map(_online).handleError((_) {}).distinct();
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield await service.isOnline();
  yield* service.changes;
});

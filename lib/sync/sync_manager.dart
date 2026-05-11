import 'package:workmanager/workmanager.dart';
import '../core/constants/app_constants.dart';
import '../core/di/injection.dart';
import '../features/users/domain/repositories/user_repository.dart';

/// WorkManager background task dispatcher.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == AppConstants.syncTaskName) {
        // We need to init DI in the background isolate
        await setupDependencies();
        final repo = getIt<UserRepository>();
        await repo.syncPendingUsers();
      }
      return true;
    } catch (_) {
      return false;
    }
  });
}

/// Initializes and schedules background sync tasks.
class SyncManager {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  /// Register a one-off sync task (triggered when connectivity returns).
  static Future<void> triggerSync() async {
    await Workmanager().registerOneOffTask(
      '${AppConstants.syncTaskName}_oneoff',
      AppConstants.syncTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Register periodic sync.
  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      '${AppConstants.syncTaskName}_periodic',
      AppConstants.syncTaskName,
      frequency: AppConstants.syncInterval,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}

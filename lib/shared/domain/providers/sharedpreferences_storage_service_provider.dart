import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/shared/data/local/shared_prefs_storage_service.dart';
import 'package:mplos_chat/shared/widgets/providers/app_state_provider.dart';

final storageServiceProvider = Provider((ref) {
  final SharedPrefsService prefsService = SharedPrefsService();
  prefsService.init(ref.read(appStateNotifierProvider).token);
  return prefsService;
});

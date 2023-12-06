import 'dart:developer';

import 'package:mplos_chat/shared/data/local/shared_prefs_storage_service.dart';

class TimerLocalDataSource {
  final SharedPrefsService storageService;
  TimerLocalDataSource(this.storageService);

  void init(String key) {
    log(key);
    storageService.init(key);
  }

  Future<Object?> getCredential() {
    return storageService.get('credential');
  }

  void saveCredential(String jsonData) {
    storageService.set('credential', jsonData);
  }
}

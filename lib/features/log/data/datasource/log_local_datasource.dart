import 'dart:convert';
import 'dart:developer';

import 'package:mplos_chat/shared/data/local/shared_prefs_storage_service.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';

class LogLocalDataSource {
  final SharedPrefsService storageService;
  LogLocalDataSource(this.storageService);

  void init(String key) {
    log(key);
    storageService.init(key);
  }

  Future<Object?> getActivty(DateTime dateTime) {
    String strDate = "${dateTime.day}.${dateTime.month}.${dateTime.year}";

    return storageService.get(strDate);
  }

  void setActivity(List<Software> activities, DateTime dateTime) {
    String strDate = "${dateTime.day}.${dateTime.month}.${dateTime.year}";
    storageService.set(
        strDate, jsonEncode(activities.map((e) => e.toJson()).toList()));
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show FormData, MultipartFile;

import 'package:mplos_chat/shared/data/remote/remote.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

class TimerDataSource {
  final NetworkService networkService;
  TimerDataSource(this.networkService);

  void setDefaultParams({required Map<String, dynamic> data}) {
    networkService.updateDefaultParams(data);
  }

  Future<Either<AppException, Response>> signIn(
      {required String username, required String password}) async {
    final response = await networkService.get('?api=login',
        queryParameters: {"username": username, "password": password});

    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> getMissions(
      {required String token, required int companyID}) async {
    final response = await networkService.get('?api=daily_work',
        queryParameters: {
          "action": "get_missions",
          "token": token,
          "company_id": companyID
        });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> getMissionStatus(
      {required String token,
      required int companyID,
      required int missionID}) async {
    final response =
        await networkService.get('?api=get_mission_status', queryParameters: {
      "token": token,
      "company_id": companyID,
      "mission_id": missionID,
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> changeMissionStatus(
      {required String token,
      required int companyID,
      required int missionID,
      required int status}) async {
    final response =
        await networkService.get('?api=mission_status', queryParameters: {
      "token": token,
      "company_id": companyID,
      "mission_id": missionID,
      "status": status
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> startDailyWork(
      {required int companyID,
      required String token,
      required int missionID}) async {
    var queryParam = {
      'action': 'start',
      'company_id': companyID,
      'token': token
    };
    if (missionID != -1) {
      queryParam['select_mission'] = missionID;
    }
    final response = await networkService.get('?api=daily_work',
        queryParameters: queryParam);
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> pauseResumeWork(
      {required String actionType,
      required String token,
      required int companyID}) async {
    final response = await networkService.get('?api=daily_work',
        queryParameters: {
          "action": actionType,
          "token": token,
          "company_id": companyID
        });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> endWork(
      {required String token, required int companyID}) async {
    final response = await networkService.get('?api=daily_work',
        queryParameters: {
          "action": "endofday",
          "token": token,
          "company_id": companyID
        });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> sendReport(
      {required String token,
      required int companyID,
      required List<String> selectUsers}) async {
    final response =
        await networkService.get('?api=daily_work', queryParameters: {
      "action": "sendreport",
      "token": token,
      "company_id": companyID,
      "select_users": selectUsers.join(",")
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> signOut(
      {required String token, required int companyID}) async {
    final response = await networkService.get('?api=app_logout',
        queryParameters: {"token": token, "company_id": companyID});
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> switchCompany(
      {required String token,
      required int companyID,
      required int targetID}) async {
    final response = await networkService.get('?api=switch_company',
        queryParameters: {
          "token": token,
          "company_id": companyID,
          "target_id": targetID
        });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> getCompanySetting(
      {required String token}) async {
    final response =
        await networkService.get('?api=get_company_settings', queryParameters: {
      "token": token,
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> sendScreenshot(
      {required String token,
      required int companyID,
      required String path,
      required String appName,
      required String time,
      required int duration}) async {
    log('Sending File($path)');
    FormData formData = FormData.fromMap({
      'api': 'screenshot',
      'token': token,
      'company_id': companyID,
      'screenshot_file': MultipartFile.fromFileSync(path),
      'task_name': appName,
      'task_time': time,
      'task_duration': duration,
      'app_name': appName,
      // 'time': time
    });
    final response = await networkService.sendFile('', formData: formData);
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> sendLog(
      {required String token,
      required int companyID,
      required String date,
      required String logData}) async {
    final response = await networkService.get('?api=log', queryParameters: {
      'token': token,
      'company_id': companyID,
      'date': date,
      'log': logData
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }
}

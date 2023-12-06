import 'package:dartz/dartz.dart';

import 'package:mplos_chat/features/timer/domain/repositories/timer_repository.dart';
import 'package:mplos_chat/features/timer/data/datasource/timer_remote_data_source.dart';
import 'package:mplos_chat/features/timer/data/datasource/timer_local_data_source.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

class TimerRepositoryImpl extends TimerRepository {
  final TimerDataSource remoteDataSource;
  final TimerLocalDataSource localDataSource;

  TimerRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<Object?> getCredential() {
    return localDataSource.getCredential();
  }

  @override
  void saveCredential({required String credential}) {
    return localDataSource.saveCredential(credential);
  }

  @override
  void setDefaultParams({required Map<String, dynamic> data}) {
    return remoteDataSource.setDefaultParams(data: data);
  }

  @override
  Future<Either<AppException, Response>> signIn(
      {required String username, required String password}) {
    return remoteDataSource.signIn(username: username, password: password);
  }

  @override
  Future<Either<AppException, Response>> getMissions(
      {required String token, required int companyID}) {
    return remoteDataSource.getMissions(token: token, companyID: companyID);
  }

  @override
  Future<Either<AppException, Response>> getMissionStatus(
      {required String token, required int companyID, required int missionID}) {
    return remoteDataSource.getMissionStatus(
        token: token, companyID: companyID, missionID: missionID);
  }

  @override
  Future<Either<AppException, Response>> changeMissionStatus(
      {required String token,
      required int companyID,
      required int missionID,
      required int status}) {
    return remoteDataSource.changeMissionStatus(
        token: token,
        companyID: companyID,
        missionID: missionID,
        status: status);
  }

  @override
  Future<Either<AppException, Response>> startDailyWork(
      {required int companyID, required String token, required int missionID}) {
    return remoteDataSource.startDailyWork(
        companyID: companyID, token: token, missionID: missionID);
  }

  @override
  Future<Either<AppException, Response>> pauseResumeWork(
      {required String actionType,
      required String token,
      required int companyID}) {
    return remoteDataSource.pauseResumeWork(
        actionType: actionType, token: token, companyID: companyID);
  }

  @override
  Future<Either<AppException, Response>> endWork(
      {required String token, required int companyID}) {
    return remoteDataSource.endWork(token: token, companyID: companyID);
  }

  @override
  Future<Either<AppException, Response>> sendReport(
      {required String token,
      required int companyID,
      required List<String> selectUsers}) {
    return remoteDataSource.sendReport(
        token: token, companyID: companyID, selectUsers: selectUsers);
  }

  @override
  Future<Either<AppException, Response>> signOut(
      {required String token, required int companyID}) {
    return remoteDataSource.signOut(token: token, companyID: companyID);
  }

  @override
  Future<Either<AppException, Response>> getCompanySetting(
      {required String token}) {
    return remoteDataSource.getCompanySetting(token: token);
  }

  @override
  Future<Either<AppException, Response>> sendScreenshot(
      {required String token,
      required int companyID,
      required String path,
      required String appName,
      required String time,
      required int duration}) {
    return remoteDataSource.sendScreenshot(
        token: token,
        companyID: companyID,
        path: path,
        appName: appName,
        time: time,
        duration: duration);
  }

  @override
  Future<Either<AppException, Response>> sendLog(
      {required String token,
      required int companyID,
      required String date,
      required String logData}) {
    return remoteDataSource.sendLog(
        token: token, companyID: companyID, date: date, logData: logData);
  }
}

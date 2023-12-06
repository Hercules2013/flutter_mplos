import 'package:dartz/dartz.dart';
// import 'package:mplos_chat/shared/domain/models/paginated_response.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

abstract class TimerRepository {
  // local db
  Future<Object?> getCredential();
  void saveCredential({required String credential});

  // remote
  void setDefaultParams({required Map<String, dynamic> data});
  Future<Either<AppException, Response>> signIn(
      {required String username, required String password});
  Future<Either<AppException, Response>> getMissions(
      {required String token, required int companyID});
  Future<Either<AppException, Response>> getMissionStatus(
      {required int companyID, required String token, required int missionID});
  Future<Either<AppException, Response>> changeMissionStatus(
      {required String token,
      required int companyID,
      required int missionID,
      required int status});
  Future<Either<AppException, Response>> startDailyWork(
      {required int companyID, required String token, required int missionID});
  Future<Either<AppException, Response>> sendReport(
      {required String token,
      required int companyID,
      required List<String> selectUsers});
  Future<Either<AppException, Response>> pauseResumeWork(
      {required String actionType,
      required String token,
      required int companyID});
  Future<Either<AppException, Response>> endWork(
      {required String token, required int companyID});
  Future<Either<AppException, Response>> signOut(
      {required String token, required int companyID});
  // Future<Either<AppException, Response>> switchCompany(
  //     {required String token, required int companyID, required int targetID});
  Future<Either<AppException, Response>> getCompanySetting(
      {required String token});
  Future<Either<AppException, Response>> sendScreenshot(
      {required String token,
      required int companyID,
      required String path,
      required String appName,
      required String time,
      required int duration});
  Future<Either<AppException, Response>> sendLog(
      {required String token,
      required int companyID,
      required String date,
      required String logData});
}

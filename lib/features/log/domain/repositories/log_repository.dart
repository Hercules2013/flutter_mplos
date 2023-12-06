import 'package:dartz/dartz.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

abstract class LogRepository {
  // Local DB
  Future<Object?> getActivity({required DateTime dateTime});
  void setActivity(
      {required List<Software> softwares, required DateTime dateTime});

  // Remote
  Future<Either<AppException, Response>> requestProgram(String software);
}

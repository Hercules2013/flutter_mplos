import 'package:dartz/dartz.dart';
import 'package:mplos_chat/features/log/data/datasource/log_local_datasource.dart';
import 'package:mplos_chat/features/log/data/datasource/log_remote_datasource.dart';
import 'package:mplos_chat/features/log/domain/repositories/log_repository.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

class LogRepositoryImpl extends LogRepository {
  final LogLocalDataSource localSource;
  final LogRemoteDataSource remoteSource;
  LogRepositoryImpl(this.localSource, this.remoteSource);

  @override
  void setActivity(
      {required List<Software> softwares, required DateTime dateTime}) {
    localSource.setActivity(softwares, dateTime);
  }

  @override
  Future<Object?> getActivity({required DateTime dateTime}) {
    return localSource.getActivty(dateTime);
  }

  @override
  Future<Either<AppException, Response>> requestProgram(String software) {
    return remoteSource.requestProgram(software: software);
  }
}

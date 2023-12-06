import 'package:dartz/dartz.dart';
import 'package:mplos_chat/shared/data/remote/network_service.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

class LogRemoteDataSource {
  final NetworkService networkService;
  LogRemoteDataSource(this.networkService);

  Future<Either<AppException, Response>> requestProgram(
      {required String software}) async {
    final response = await networkService.post('?api=request_program', data: {
      'software_name': software,
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }
}

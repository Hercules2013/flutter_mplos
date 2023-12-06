import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show FormData;
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

abstract class NetworkService {
  String get baseUrl;

  Map<String, Object> get headers;
  Map<String, Object> defaultParams = {};

  void updateHeader(Map<String, dynamic> data);

  void updateDefaultParams(Map<String, dynamic> data);

  Future<Either<AppException, Response>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });

  Future<Either<AppException, Response>> post(
    String endpoint, {
    Map<String, dynamic>? data,
  });

  Future<Either<AppException, Response>> sendFile(String endpoint,
      {FormData formData});
}

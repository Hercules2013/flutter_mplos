import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/configs/app_configs.dart';
import 'package:mplos_chat/shared/data/remote/network_service.dart';
import 'package:mplos_chat/shared/domain/models/response.dart' as response;
import 'package:mplos_chat/shared/exceptions/http_exception.dart';
import 'package:mplos_chat/shared/globals.dart';
import 'package:mplos_chat/shared/mixins/exception_handler_mixin.dart';

class DioNetworkService extends NetworkService with ExceptionHandlerMixin {
  final Dio dio;
  final container = ProviderContainer();
  DioNetworkService(this.dio) {
    // this throws error while running test
    if (!kTestMode) {
      dio.options = dioBaseOptions;
      if (kDebugMode) {
        dio.interceptors
            .add(LogInterceptor(requestBody: false, responseBody: false));
      }
    }
  }

  BaseOptions get dioBaseOptions => BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
      );
  @override
  String get baseUrl => AppConfigs.baseUrl;

  @override
  Map<String, Object> get headers => {
        'accept': 'application/json',
        'content-type': 'application/json',
      };

  @override
  Map<String, dynamic>? updateHeader(Map<String, dynamic> data) {
    final header = {...data, ...headers};
    if (!kTestMode) {
      dio.options.headers = header;
    }
    return header;
  }

  @override
  void updateDefaultParams(Map<String, dynamic> data) {
    defaultParams = {...data, ...defaultParams};
  }

  @override
  Future<Either<AppException, response.Response>> post(String endpoint,
      {Map<String, dynamic>? data}) {
    final updatedData = {
      ...defaultParams,
      ...?data,
    };
    final res = handleException(
      () => dio.post(
        endpoint,
        data: FormData.fromMap(updatedData),
      ),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) {
    final updatedQueryParamters = {
      ...defaultParams,
      ...?queryParameters,
    };
    final res = handleException(
      () => dio.get(
        endpoint,
        queryParameters: updatedQueryParamters,
      ),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> sendFile(String endpoint,
      {FormData? formData}) {
    final res = handleException(
        () => dio.post(endpoint,
            data: formData,
            options: Options(
              headers: {'Content-Type': 'multipart/form-data'},
            )),
        endpoint: endpoint);
    return res;
  }
}

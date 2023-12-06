import 'package:dio/dio.dart';
import 'package:mplos_chat/shared/data/remote/dio_network_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final netwokServiceProvider = Provider<DioNetworkService>(
  (ref) {
    final Dio dio = Dio();
    dio.interceptors
        .add(LogInterceptor(requestBody: false, responseBody: false));
    return DioNetworkService(dio);
  },
);

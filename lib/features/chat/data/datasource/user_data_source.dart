import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show MultipartFile;
// import 'pacakge:dio/m';
import 'package:mplos_chat/shared/data/remote/remote.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

class UserDataSource {
  final NetworkService networkService;
  UserDataSource(this.networkService);

  void setDefaultParams({required Map<String, dynamic> data}) {
    networkService.updateDefaultParams(data);
  }

  Future<Either<AppException, Response>> fetchUsers({required int page}) async {
    final response = await networkService
        .get('?api=get_chats', queryParameters: {"page": page, "search": ""});
    // final response = await networkService
    //     .get('?api=daily_work', queryParameters: {"action": 'get_users'});

    return response.fold((l) => Left(l), (r) {
      // final jsonData = jsonDecode(r.data);

      // if (jsonData == null || jsonData['status'] == false) {
      //   return Left(
      //     AppException(
      //       identifier: 'fetch user data',
      //       statusCode: 0,
      //       message: jsonData['message'],
      //     ),
      //   );
      // }
      return Right(r);
    });
  }

  Future<Either<AppException, Response>> fetchMessages(
      {required String userID,
      required String isGroup,
      required int page}) async {
    final response = await networkService.get('?api=get_chat',
        queryParameters: {
          "user_id": userID,
          "Is_Group": isGroup,
          "page": page
        });

    return response.fold((l) => Left(l), (r) {
      final jsonData = jsonDecode(r.data);

      if (jsonData == null || jsonData['status'] == false) {
        return Left(
          AppException(
            identifier: 'fetch message data',
            statusCode: 0,
            message: jsonData['message'],
          ),
        );
      }
      return Right(r);
    });
  }

  Future<Either<AppException, Response>> sendMessage(
      {required String message,
      required String isGroup,
      required String userID,
      required String replyID}) async {
    final response = await networkService.post('?api=send_message', data: {
      'message': message,
      'is_Group': isGroup,
      'receiver': userID,
      'replay': replyID == '' ? null : replyID
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> sendFile(
      {required String file,
      required String userID,
      required String isGroup}) async {
    final response = await networkService.post('?api=send_message', data: {
      'receiver': userID,
      'is_Group': isGroup,
      'files[]': MultipartFile.fromFileSync(file)
    });

    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> toggleNotificaiton(
      {required String isGroup, required String userID}) async {
    final response = await networkService
        .get('?api=chat_notification_mode', queryParameters: {
      "is_Group": isGroup,
      "user_id": userID,
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> markAsRead(
      {required String isGroup, required String userID}) async {
    final response =
        await networkService.get('?api=mark_read', queryParameters: {
      "Is_Group": isGroup,
      "id": userID,
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> clearHistory(
      {required String isGroup, required String userID}) async {
    final response =
        await networkService.get('?api=clear_chat_history', queryParameters: {
      "Is_Group": isGroup,
      "user_id": userID,
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> leaveChat(
      {required String groupID}) async {
    final response =
        await networkService.get('?api=leave_group', queryParameters: {
      "group_id": groupID,
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> deleteGroup(
      {required String deleteID, required String isGroup}) async {
    final response =
        await networkService.get('?api=delete_chat', queryParameters: {
      "delete_id": deleteID,
      "is_group": isGroup,
    });
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> editMessage(
      {required String msgID, required String message}) async {
    final response = await networkService
        .post('?api=edit_message', data: {'msg_id': msgID, 'message': message});
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> forwardMessage(
      {required String receivers, required String msgID}) async {
    final response = await networkService.post('?api=forward_message',
        data: {'receivers': receivers, 'msg_id': msgID});
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> deleteMessage(
      {required String msgID, required String isGroup}) async {
    final response = await networkService.post('?api=delete_message',
        data: {'msg_id': msgID, 'is_group': isGroup});
    return response.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<AppException, Response>> deleteChat(
      {required String msgID, required String isGroup}) async {
    final response = await networkService.get('?api=delete_chat',
        queryParameters: {'delete_id': msgID, 'is_group': isGroup});
    return response.fold((l) => Left(l), (r) => Right(r));
  }
}

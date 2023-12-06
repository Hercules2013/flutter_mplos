import 'package:dartz/dartz.dart';

import 'package:mplos_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:mplos_chat/features/chat/data/datasource/user_data_source.dart';
import 'package:mplos_chat/features/chat/data/datasource/chat_data_source.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

class ChatRepositoryImpl extends ChatRepository {
  final UserDataSource userDataSource;
  final ChatDataSource chatDataSource;

  ChatRepositoryImpl(this.userDataSource, this.chatDataSource);

  @override
  void setDefaultParams({required Map<String, dynamic> data}) {
    return userDataSource.setDefaultParams(data: data);
  }

  @override
  Future<Either<AppException, Response>> fetchUsers({required int page}) {
    return userDataSource.fetchUsers(page: page);
  }

  @override
  Future<Either<AppException, Response>> fetchMessages(
      {required String userID, required String isGroup, required int page}) {
    return userDataSource.fetchMessages(
        userID: userID, isGroup: isGroup, page: page);
  }

  @override
  Future<Either<AppException, Response>> sendMessage(
      {required String message,
      required String isGroup,
      required String userID,
      required String replyID}) {
    return userDataSource.sendMessage(
        message: message, isGroup: isGroup, userID: userID, replyID: replyID);
  }

  @override
  Future<Either<AppException, Response>> sendFile(
      {required String file, required String userID, required String isGroup}) {
    return userDataSource.sendFile(
        file: file, userID: userID, isGroup: isGroup);
  }

  @override
  Future<Either<AppException, Response>> toggleNotification(
      {required String isGroup, required String userID}) {
    return userDataSource.toggleNotificaiton(isGroup: isGroup, userID: userID);
  }

  @override
  Future<Either<AppException, Response>> markAsRead(
      {required String isGroup, required String userID}) {
    return userDataSource.markAsRead(isGroup: isGroup, userID: userID);
  }

  @override
  Future<Either<AppException, Response>> clearHistory(
      {required String isGroup, required String userID}) {
    return userDataSource.clearHistory(isGroup: isGroup, userID: userID);
  }

  @override
  Future<Either<AppException, Response>> leaveChat({required String groupID}) {
    return userDataSource.leaveChat(groupID: groupID);
  }

  @override
  Future<Either<AppException, Response>> deleteGroup(
      {required String deleteID, required String isGroup}) {
    return userDataSource.deleteGroup(deleteID: deleteID, isGroup: isGroup);
  }

  @override
  Future<Either<AppException, Response>> editMessage(
      {required String msgID, required String message}) {
    return userDataSource.editMessage(msgID: msgID, message: message);
  }

  @override
  Future<Either<AppException, Response>> forwardMessage(
      {required String receivers, required String msgID}) {
    return userDataSource.forwardMessage(receivers: receivers, msgID: msgID);
  }

  @override
  Future<Either<AppException, Response>> deleteMessage(
      {required String msgID, required String isGroup}) {
    return userDataSource.deleteMessage(msgID: msgID, isGroup: isGroup);
  }
}

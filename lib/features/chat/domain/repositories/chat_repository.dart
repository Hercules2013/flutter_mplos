import 'package:dartz/dartz.dart';
// import 'package:mplos_chat/shared/domain/models/paginated_response.dart';
import 'package:mplos_chat/shared/domain/models/response.dart';
import 'package:mplos_chat/shared/exceptions/http_exception.dart';

abstract class ChatRepository {
  void setDefaultParams({required Map<String, dynamic> data});
  Future<Either<AppException, Response>> fetchUsers({required int page});
  Future<Either<AppException, Response>> fetchMessages(
      {required String userID, required String isGroup, required int page});

  Future<Either<AppException, Response>> sendMessage(
      {required String message,
      required String isGroup,
      required String userID,
      required String replyID});

  Future<Either<AppException, Response>> sendFile(
      {required String file, required String userID, required String isGroup});

  Future<Either<AppException, Response>> toggleNotification(
      {required String isGroup, required String userID});
  Future<Either<AppException, Response>> markAsRead(
      {required String isGroup, required String userID});
  Future<Either<AppException, Response>> clearHistory(
      {required String isGroup, required String userID});
  Future<Either<AppException, Response>> leaveChat({required String groupID});
  Future<Either<AppException, Response>> deleteGroup(
      {required String deleteID, required String isGroup});
  Future<Either<AppException, Response>> editMessage(
      {required String msgID, required String message});
  Future<Either<AppException, Response>> forwardMessage(
      {required String receivers, required String msgID});
  Future<Either<AppException, Response>> deleteMessage(
      {required String msgID, required String isGroup});
}

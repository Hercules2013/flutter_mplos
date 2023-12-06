import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/domain/models/chat/message_model.dart';

enum ChatConcreteState {
  initial,

  loadingUsers,
  loadedUsers,
  failureUsers,
  fetchingMoreUsers,
  fetchedAllUsers,

  loadingMessages,
  loadedMessages,
  failureMessages,
  fetchingMoreMessages,
  fetchedAllMessages,
}

enum FooterConcreateState { normal, select, record }

class ChatState {
  final List<User> users;
  final String filterOption, sortOption;
  final int activeID;
  User? activeUser;
  final ChatConcreteState state;
  final String message;
  final bool isLoadingUsers, isLoadingMessages;
  final int pageUser, pageMessage;
  final List<Message> messages;
  final List<Message> selectedMessages;
  final String replyID;
  final FooterConcreateState footerState;
  final bool gotNewMessage;

  ChatState(
      {this.users = const [],
      this.filterOption = "",
      this.sortOption = "",
      this.activeUser,
      this.activeID = -1,
      this.state = ChatConcreteState.initial,
      this.message = "",
      this.isLoadingUsers = false,
      this.isLoadingMessages = false,
      this.pageUser = 0,
      this.pageMessage = 0,
      this.messages = const [],
      this.gotNewMessage = false,
      this.selectedMessages = const [],
      this.replyID = "",
      this.footerState = FooterConcreateState.normal});

  ChatState.initial(
      {this.users = const [],
      this.filterOption = "",
      this.sortOption = "",
      this.activeID = -1,
      this.activeUser,
      this.state = ChatConcreteState.initial,
      this.message = "",
      this.isLoadingUsers = false,
      this.isLoadingMessages = false,
      this.pageUser = 0,
      this.pageMessage = 0,
      this.messages = const [],
      this.gotNewMessage = false,
      this.selectedMessages = const [],
      this.replyID = "",
      this.footerState = FooterConcreateState.normal});

  List<User> get filteredUsers =>
      users.where((user) => user.name.contains(filterOption)).toList();

  ChatState copyWith(
      {List<User>? users,
      String? filterOption,
      String? sortOption,
      int? activeID,
      User? activeUser,
      ChatConcreteState? state,
      String? message,
      bool? isLoadingUsers,
      bool? isLoadingMessages,
      int? pageUser,
      int? pageMessage,
      List<Message>? messages,
      bool? gotNewMessage,
      List<Message>? selectedMessages,
      String? replyID,
      FooterConcreateState? footerState}) {
    return ChatState(
        users: users ?? this.users,
        filterOption: filterOption ?? this.filterOption,
        sortOption: sortOption ?? this.sortOption,
        activeID: activeID ?? this.activeID,
        activeUser: activeUser ?? this.activeUser,
        state: state ?? this.state,
        message: message ?? this.message,
        isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
        isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
        pageUser: pageUser ?? this.pageUser,
        pageMessage: pageMessage ?? this.pageMessage,
        messages: messages ?? this.messages,
        gotNewMessage: gotNewMessage ?? this.gotNewMessage,
        selectedMessages: selectedMessages ?? this.selectedMessages,
        replyID: replyID ?? this.replyID,
        footerState: footerState ?? this.footerState);
  }
}

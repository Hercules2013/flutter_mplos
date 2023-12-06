import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mplos_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:mplos_chat/features/chat/presentation/providers/state/chat_state.dart';

import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/domain/models/chat/message_model.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository chatRepository;

  ChatNotifier({required this.chatRepository}) : super(ChatState.initial());

  bool get isFetching =>
      state.state != ChatConcreteState.loadingUsers &&
      state.state != ChatConcreteState.fetchingMoreUsers;

  void setDefaultParameter(Map<String, dynamic> data) {
    chatRepository.setDefaultParams(data: data);
  }

  Future<void> fetchUsers() async {
    if (state.state == ChatConcreteState.loadingUsers) return;

    state = state.copyWith(
        state: ChatConcreteState.fetchingMoreUsers, isLoadingUsers: true);
    final response = await chatRepository.fetchUsers(page: state.pageUser + 1);
    response.fold((failure) {
      // state = state.copyWith(
      //   state: ChatConcreteState.fetchedAllUsers,
      //   message: 'No more users available',
      //   isLoadingUsers: false,
      // );
      state = state.copyWith(
          state: ChatConcreteState.failureUsers,
          message: 'Check your internet connection',
          isLoadingUsers: false);
    }, (data) {
      // if status code is not 200, error with API call
      if (data.statusCode != 200) {
        state = state.copyWith(
            state: ChatConcreteState.failureUsers,
            message: data.statusMessage,
            isLoadingUsers: false);
      } else {
        final jsonData = jsonDecode(data.data.toString());

        if (jsonData['status'] == false) {
          state = state.copyWith(
              state: ChatConcreteState.loadedUsers,
              message: 'Fetch Users Failed',
              isLoadingUsers: false);
        } else {
          Map<String, Status> statusArr = {
            '0': Status.offline,
            '1': Status.online,
            '2': Status.away,
            '3': Status.onbreak,
            '4': Status.oncall,
            'null': Status.onnull
          };
          state = state.copyWith(
              state: ChatConcreteState.loadedUsers,
              users: [
                ...state.users,
                ...(jsonData['chats']['UserList'] as List<dynamic>)
                    // ...(jsonData['users'] as List<dynamic>)
                    .where((user) => user['conversation'] != null)
                    .map((user) {
                  return User(
                      id: user['receiver'],
                      name: user['conversation']['name'],
                      avatar: user['conversation']['receiver_profile_url']
                          .toString(),
                      color: user['conversation']['receiver_profile_color']
                          .toString(),
                      unReadCount: user['conversation']['newmessage_count'],
                      status: statusArr[
                          user['conversation']['user_status'].toString()]!,
                      lastMessage: user['conversation']['last_update']
                          ['message'],
                      lastTime: utc2gmt(user['conversation']['last_update']
                              ['recenttime']
                          .toString()),
                      isNotificationMuted:
                          user['conversation']['notification_mode'] == "yes",
                      type: user['conversation']['type'],
                      isGroupAdmin:
                          user['conversation']['is_group_admin'].toString(),
                      chatID: user['chat_conversation_id']);
                  // return User(
                  //     id: user['id'],
                  //     name: user['name'],
                  //     avatar: user['profile'].toString(),
                  //     color: user['user_color'].toString(),
                  //     unReadCount: 0,
                  //     status: statusArr[
                  //         user['conversation']['user_status'].toString()]!,
                  //     lastMessage: user['conversation']['last_update']
                  //         ['message'],
                  //     lastTime: Utc2Gmt(user['conversation']['last_update']
                  //             ['recenttime']
                  //         .toString()),
                  //     isNotificationMuted:
                  //         user['conversation']['notification_mode'] == "yes",
                  //     type: user['conversation']['type'],
                  //     isGroupAdmin:
                  //         user['conversation']['is_group_admin'].toString());
                }).toList()
              ],
              pageUser: state.pageUser + 1,
              isLoadingUsers: false);
        }
      }
    });
  }

  Future<void> searchUsers(String searchText) async {
    // final response = await chatRepository.fetchUsers(search: searchText);
  }

  void resetState() {
    state = ChatState.initial();
  }

  void addUsers(List<User> users) {
    state = state.copyWith(users: [...state.users, ...users]);
  }

  void filterUsers(String filterOption) {
    state = state.copyWith(filterOption: filterOption);
  }

  void sortUsers(String sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void setActiveUser(User user) {
    if (state.activeUser == user) return;

    state = state.copyWith(
        activeUser: user,
        activeID: state.users.indexOf(user),
        users: state.users
            .map((u) => u.id == user.id ? u.copyWith(unReadCount: 0) : u)
            .toList(),
        messages: [],
        replyID: '',
        pageMessage: 1,
        footerState: FooterConcreateState.normal,
        selectedMessages: []);
  }

  Future<void> fetchMessages() async {
    if (state.activeUser == null ||
        state.state == ChatConcreteState.loadingMessages) return;

    state = state.copyWith(
        state: ChatConcreteState.fetchingMoreMessages, isLoadingMessages: true);
    final response = await chatRepository.fetchMessages(
        userID: state.activeUser!.id,
        isGroup: state.activeUser!.type == 'group' ? "yes" : "no",
        page: state.pageMessage);

    log("Fetch Messages: ${state.activeUser!.id} ${state.pageMessage}");

    response.fold((failure) {
      state = state.copyWith(
        state: ChatConcreteState.fetchedAllUsers,
        message: 'No more users available',
        isLoadingMessages: false,
      );
    }, (data) {
      final jsonData = jsonDecode(data.data.toString());
      state = state.copyWith(
          state: ChatConcreteState.loadedMessages,
          messages: [
            ...(jsonData['chat'] as List<dynamic>).map((msg) {
              return Message(
                  id: msg['id'],
                  sender: msg['sender'],
                  receiver: msg['receiver'],
                  message: msg['message'],
                  type: msg['msg_type'],
                  isGroupMessage: msg['is_group_msg'] == "yes",
                  isEdited: msg['edited'].toString() == "yes",
                  sendTime: utc2gmt(msg['time']),
                  readTime: utc2gmt(msg['msg_read'].length == 0
                      ? "null"
                      : msg['msg_read'][0]['timestamp']),
                  medias: (msg['chat_media'] as List<dynamic>)
                      .where((media) => media.toString() != '[]')
                      .map((media) => ChatMedia(
                          url: media['url'].toString(),
                          type: media['media_type'].toString()))
                      .toList(),
                  replyID: msg['replied_message'].toString() != "[]"
                      ? msg['replied_message']['id']
                      : '',
                  replyText: msg['replied_message'].toString() != "[]"
                      ? msg['replied_message']['message']
                      : '',
                  replyMedias: msg['replied_message'].toString() != "[]"
                      ? (msg['replied_message']['chat_media'] as List<dynamic>)
                          .map((m) =>
                              ChatMedia(type: m['media_type'], url: m['url']))
                          .toList()
                      : [],
                  forwardText: msg['forwarded_message'].toString() != "[]"
                      ? msg['forwarded_message']['message']
                      : '');
            }).toList(),
            ...state.messages
          ],
          pageMessage: state.pageMessage + 1,
          isLoadingMessages: false);
    });
  }

  void sendMessage(Message msg, String replyID) async {
    // state = state.copyWith(
    //     activeUser: state.activeUser!
    //         .copyWith(messages: [...state.activeUser!.messages, msg]));
    state = state.copyWith(messages: [...state.messages, msg]);

    final response = await chatRepository.sendMessage(
        message: msg.message,
        isGroup: state.activeUser!.type == "user" ? "no" : "yes",
        userID: msg.receiver,
        replyID: replyID);

    response.fold((failure) {
      log(failure.message.toString());
    }, (data) {
      log('Send Message');
      log(data.data);

      final jsonData = jsonDecode(data.data.toString());

      state = state.copyWith(
          users: state.users
              .map((user) => user.id == state.activeUser!.id
                  ? user.copyWith(
                      lastMessage: msg.message,
                      lastTime: DateTime.now().toString())
                  : user)
              .toList(),
          messages: [
            ...state.messages.sublist(0, state.messages.length - 1),
            msg.copyWith(id: jsonData['msg_id'])
          ]);
    });
  }

  void sendFile(Message msg) async {
    state = state.copyWith(messages: [...state.messages, msg]);

    final response = await chatRepository.sendFile(
        file: msg.medias.first.url,
        userID: msg.receiver,
        isGroup: msg.isGroupMessage ? "yes" : "no");

    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());

      if (jsonData['status']) {
        state = state.copyWith(
            users: state.users
                .map((user) => user.id == state.activeUser!.id
                    ? user.copyWith(
                        lastMessage: "File ${msg.medias.first.url}",
                        lastTime: DateTime.now().toString())
                    : user)
                .toList(),
            messages: [
              ...state.messages.sublist(0, state.messages.length - 1),
              msg.copyWith(id: jsonData['msg_id'], medias: [
                ChatMedia(
                    url: jsonData['fileUrl'][0], type: msg.medias.first.type)
              ])
            ]);
      }
    });
  }

  void receiveMessage(Message msg, String sender, String receiver) {
    String activeUserID = state.activeUser == null ? "" : state.activeUser!.id;
    if (sender == activeUserID) {
      state = state.copyWith(messages: [...state.messages, msg]);
    } else if (receiver == activeUserID) {
      state = state.copyWith(messages: [...state.messages, msg]);
    }
    state = state.copyWith(
        gotNewMessage: true,
        users: state.users
            .map((user) => user.id == sender
                ? activeUserID == user.id
                    ? user.copyWith(
                        lastMessage: msg.message,
                        lastTime: DateTime.now().toString())
                    : user.copyWith(
                        unReadCount: user.unReadCount + 1,
                        lastMessage: msg.message,
                        lastTime: DateTime.now().toString())
                : user)
            .toList());
  }

  void scrollToNewMessage() {
    state = state.copyWith(gotNewMessage: false);
  }

  void toggleNotification() async {
    final response = await chatRepository.toggleNotification(
      userID: state.activeUser!.id,
      isGroup: state.activeUser!.type == 'group' ? "yes" : "no",
    );

    response.fold((failure) {}, (data) {
      log(data.data);
      final jsonData = jsonDecode(data.data.toString());

      if (jsonData['status']) {
        bool isNotificationMuted =
            jsonData['notifications_status'] == 'disable';

        List<User> updatedUsers = state.users;
        updatedUsers[state.activeID] = updatedUsers[state.activeID]
            .copyWith(isNotificationMuted: isNotificationMuted);

        state = state.copyWith(
            users: updatedUsers,
            activeUser: state.activeUser!
                .copyWith(isNotificationMuted: isNotificationMuted));
      }
    });
  }

  void markAsRead() async {
    final response = await chatRepository.markAsRead(
        isGroup: state.activeUser!.type == 'group' ? "yes" : "no",
        userID: state.activeUser!.id);

    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());

      if (jsonData['status']) {
        log(jsonData['message']);
      }
    });
  }

  void setReplyMessage(id) {
    state = state.copyWith(replyID: id);
  }

  void clearHistory() async {
    final response = await chatRepository.clearHistory(
        isGroup: state.activeUser!.type == 'group' ? "yes" : "no",
        userID: state.activeUser!.id);

    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());

      if (jsonData['status']) {
        log(jsonData['message']);
        state = state.copyWith(
          messages: [],
        );
      }
    });
  }

  void leaveChat() async {
    final response =
        await chatRepository.leaveChat(groupID: state.activeUser!.id);

    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data);
      log(jsonData['message']);
      if (jsonData['status'] == true) {
        state = state.copyWith(
            users: state.users
                .where((element) => element.id != state.activeUser!.id)
                .toList());
      }
    });
  }

  void deleteGroup() async {
    final response = await chatRepository.deleteGroup(
      deleteID: state.activeUser!.id,
      isGroup: state.activeUser!.type == 'group' ? "yes" : "no",
    );

    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data);
      log(jsonData.toString());
      if (jsonData['status'] == true) {
        state = state.copyWith(
            users: state.users
                .where((element) => element.id != state.activeUser!.id)
                .toList(),
            messages: []);
        state.activeUser = null;
      }
    });
  }

  void toggleChecking(bool value) {
    state = state.copyWith(
        footerState:
            value ? FooterConcreateState.select : FooterConcreateState.normal,
        selectedMessages: [],
        messages: state.messages
            .map((message) => message.copyWith(isChecked: false))
            .toList());
  }

  void toggleCheck(Message message, bool value) {
    List<Message> updatedMessages = state.messages;
    int activeMessageID = updatedMessages.indexOf(message);
    if (activeMessageID == -1) return;

    updatedMessages[activeMessageID] =
        updatedMessages[activeMessageID].copyWith(isChecked: value);
    state = state.copyWith(messages: updatedMessages);

    if (value) {
      state = state
          .copyWith(selectedMessages: [...state.selectedMessages, message]);
    } else {
      state = state.copyWith(
          selectedMessages: state.selectedMessages
              .where((element) => element != message)
              .toList());
    }
  }

  void editMessage(Message message, String newText) async {
    final response =
        await chatRepository.editMessage(msgID: message.id, message: newText);

    response.fold((failure) {}, (data) {
      // final jsonData = jsonDecode(data.data);
      // if (jsonData['status'] == true) {
      List<Message> updateMessages = state.messages.map((msg) {
        if (msg.id == message.id) {
          return msg.copyWith(message: newText, isEdited: true);
        } else if (msg.replyID == message.id) {
          return msg.copyWith(replyText: newText);
        }
        return msg;
      }).toList();
      // int index = updateMessages.indexOf(message);
      // updateMessages[index] = updateMessages[index].copyWith(message: newText);
      state = state.copyWith(messages: updateMessages);
      // }
    });
  }

  void forwardMessage(String receiver, String msgID) async {
    final response =
        await chatRepository.forwardMessage(receivers: receiver, msgID: msgID);

    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data);
      log(jsonData.toString());
      if (jsonData['status']) {
        state = state.copyWith(
            users: state.users
                .map((user) => user.id == receiver
                    ? user.copyWith(
                        lastMessage: state.messages
                            .where((msg) => msg.id == msgID)
                            .first
                            .message,
                        lastTime: DateTime.now().toString())
                    : user)
                .toList());
      }
    });
  }

  void toggleRecording(bool value) {
    state = state.copyWith(
        footerState:
            value ? FooterConcreateState.record : FooterConcreateState.normal);
  }

  void removeMessage(Message message) async {
    final response = await chatRepository.deleteMessage(
        msgID: message.id, isGroup: message.isGroupMessage ? "yes" : "no");

    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());
      if (jsonData['status']) {
        state = state.copyWith(
            messages:
                state.messages.where((msg) => msg.id != message.id).toList());
      }
    });
  }

  void readByPeer(String id) {
    state = state.copyWith(
        users: state.users
            .map((user) => user.id != id
                ? user
                : user.copyWith(lastTime: DateTime.now().toString()))
            .toList());
    if (state.activeUser != null && id == state.activeUser!.id.toString()) {
      state = state.copyWith(
          messages: state.messages
              .map((msg) => msg.readTime == ""
                  ? msg.copyWith(readTime: DateTime.now().toString())
                  : msg)
              .toList());
    }
  }

  void refreshUserStatus(String id, String status) {
    Map<String, Status> statusArr = {
      '0': Status.offline,
      '1': Status.online,
      '2': Status.away,
      '3': Status.onbreak,
      '4': Status.oncall,
      'null': Status.onnull
    };

    state = state.copyWith(
        users: state.users
            .map((user) =>
                user.id != id ? user : user.copyWith(status: statusArr[status]))
            .toList());

    if (state.activeUser != null && state.activeUser!.id.toString() == id) {
      state = state.copyWith(
          activeUser: state.activeUser!.copyWith(status: statusArr[status]));
    }
  }

  void addEditSign(String id) {
    state = state.copyWith(
        messages: state.messages
            .map((msg) => msg.id == id ? msg.copyWith(isEdited: true) : msg)
            .toList());
  }

  String utc2gmt(String value) {
    if (value == "null") return value;

    List<String> dateNums = value.split(RegExp(r'[^0-9]'));
    DateTime zeroGMT = DateTime(
        int.parse(dateNums[0]),
        int.parse(dateNums[1]),
        int.parse(dateNums[2]),
        int.parse(dateNums[3]),
        int.parse(dateNums[4]),
        int.parse(dateNums[5]));
    return zeroGMT.add(DateTime.now().timeZoneOffset).toString();
  }

  void deleteMessage(String msgID) {
    state = state.copyWith(
        messages: state.messages.where((msg) => msg.id != msgID).toList());
  }

  void deleteChat(String chatID) {
    log(state.users.toString());
    state = state.copyWith(
        users: state.users.where((user) => user.chatID != chatID).toList());
    if (state.activeUser != null && state.activeUser!.chatID == chatID) {
      state.activeUser = null;
      state = state.copyWith(activeID: -1);
    }
  }

  void updateAudioSlider(
      String url, Duration duration, String type, bool isPlaying) {
    List<Message> messages = state.messages;
    for (var msg in messages) {
      int index = msg.medias.indexWhere((media) => media.url == url);
      if (index != -1) {
        switch (type) {
          case 'total':
            msg.medias[index] = msg.medias[index].copyWith(total: duration);
            break;
          case 'elapsed':
            msg.medias[index] = msg.medias[index].copyWith(elapsed: duration);
            break;
          case 'status':
            msg.medias[index] =
                msg.medias[index].copyWith(isPlaying: isPlaying);
            break;
        }
      }
    }
    state = state.copyWith(messages: messages);
  }
}

import 'package:equatable/equatable.dart';

enum Status { offline, online, away, onbreak, oncall, onnull }

class User extends Equatable {
  final String id;
  final String name;
  final String avatar; // URL
  final String color;
  final bool isTyping;
  final bool isPinned;
  final bool isNotificationMuted;
  final Status status;
  final int unReadCount;
  final String lastMessage;
  final String lastTime;
  // Group
  final String type;
  final String isGroupAdmin;
  final String chatID;

  const User(
      {this.id = "",
      this.name = "",
      this.avatar = "",
      this.color = "",
      this.isTyping = false,
      this.isPinned = false,
      this.isNotificationMuted = false,
      this.status = Status.online,
      this.unReadCount = 0,
      this.lastMessage = "",
      this.lastTime = "",
      this.type = "user",
      this.isGroupAdmin = "null",
      this.chatID = "-1"});

  @override
  List<Object?> get props => [
        id,
        name,
        avatar,
        color,
        isTyping,
        isPinned,
        isNotificationMuted,
        status,
        unReadCount,
        lastMessage,
        lastTime,
        type,
        isGroupAdmin,
        chatID
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'avatar': avatar,
      'color': color,
      'isTyping': isTyping,
      'isPinned': isPinned,
      'isNotificationMuted': isNotificationMuted,
      'status': status,
      'unReadCount': unReadCount,
      'lastMessage': lastMessage,
      'lastTime': lastTime,
      'type': type,
      'isGroupAdmin': isGroupAdmin,
      'chatID': chatID
    };
  }

  factory User.fromJson(Map<String, dynamic> map) => User(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      color: map['color'] ?? '#000000',
      isTyping: map['isTyping'] ?? false,
      isPinned: map['isPinned'] ?? false,
      isNotificationMuted: map['isNotificationMuted'] ?? false,
      status: map['status'] ?? Status.online,
      unReadCount: map['unReadCount'] ?? 0,
      lastMessage: map['lastMessage'] ?? '',
      lastTime: map['lastTime'] ?? '',
      type: map['type'] ?? false,
      isGroupAdmin: map['isGroupAdmin'] ?? 'null',
      chatID: map['chatID'] ?? '-1');

  User copyWith(
      {String? id,
      String? name,
      String? avatar,
      String? color,
      bool? isTyping,
      bool? isPinned,
      bool? isNotificationMuted,
      Status? status,
      int? unReadCount,
      String? lastMessage,
      String? lastTime,
      String? type,
      String? isGroupAdmin,
      String? chatID}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      color: color ?? this.color,
      isTyping: isTyping ?? this.isTyping,
      isPinned: isPinned ?? this.isPinned,
      isNotificationMuted: isNotificationMuted ?? this.isNotificationMuted,
      status: status ?? this.status,
      unReadCount: unReadCount ?? this.unReadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      type: type ?? this.type,
      isGroupAdmin: isGroupAdmin ?? this.isGroupAdmin,
      chatID: chatID ?? this.chatID,
    );
  }

  @override
  bool operator ==(Object other) => other is User && other.id == id;
}

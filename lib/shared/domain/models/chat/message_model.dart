import 'package:equatable/equatable.dart';

class ChatMedia extends Equatable {
  final String url, type;
  final Duration total, elapsed;
  final bool isPlaying;

  const ChatMedia(
      {this.url = "",
      this.type = "",
      this.elapsed = Duration.zero,
      this.total = Duration.zero,
      this.isPlaying = false});

  @override
  List<Object?> get props => [url, type, elapsed, total, isPlaying];

  ChatMedia copyWith(
      {String? url,
      String? type,
      Duration? elapsed,
      Duration? total,
      bool? isPlaying}) {
    return ChatMedia(
        url: url ?? this.url,
        type: type ?? this.type,
        elapsed: elapsed ?? this.elapsed,
        total: total ?? this.total,
        isPlaying: isPlaying ?? this.isPlaying);
  }
}

class Message extends Equatable {
  final String id;
  final String sender, receiver;
  final String message, type;
  final bool isGroupMessage, isEdited;
  final String sendTime, readTime;
  final bool isChecked;
  final List<ChatMedia> medias, replyMedias;
  final String replyID, replyText, forwardText;

  const Message(
      {this.id = "",
      this.sender = "",
      this.receiver = "",
      this.message = "",
      this.type = "",
      this.isGroupMessage = false,
      this.isEdited = false,
      this.sendTime = "",
      this.readTime = "",
      this.isChecked = false,
      this.medias = const [],
      this.replyMedias = const [],
      this.replyID = "",
      this.replyText = "",
      this.forwardText = ""});

  @override
  List<Object?> get props => [
        id,
        sender,
        receiver,
        message,
        type,
        isGroupMessage,
        isEdited,
        sendTime,
        readTime,
        isChecked,
        medias,
        replyMedias,
        replyID,
        replyText,
        forwardText
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'type': type,
      'isGroupMessage': isGroupMessage,
      'isEdited': isEdited,
      'sendTime': sendTime,
      'readTime': readTime,
      'isChecked': isChecked,
      'medias': medias,
      'replyMedias': replyMedias,
      'replyID': replyID,
      'replyText': replyText,
      'forwardText': forwardText,
    };
  }

  factory Message.fromJson(Map<String, dynamic> map) => Message(
        id: map['id'] ?? 0,
        sender: map['sender'] ?? '',
        receiver: map['receiver'] ?? '',
        message: map['message'] ?? '',
        type: map['type'] ?? '',
        isGroupMessage: map['isGroupMessage'] ?? false,
        isEdited: map['isEdited'] ?? false,
        sendTime: map['sendTime'] ?? '',
        readTime: map['readTime'] ?? '',
        isChecked: map['isChecked'] ?? false,
        medias: map['medias'] ?? [],
        replyMedias: map['replyMedias'] ?? [],
        replyID: map['replyID'] ?? '',
        replyText: map['replyText'] ?? '',
        forwardText: map['forwardText'] ?? '',
      );

  Message copyWith(
      {String? id,
      String? sender,
      String? receiver,
      String? message,
      String? type,
      bool? isGroupMessage,
      bool? isEdited,
      String? sendTime,
      String? readTime,
      bool? isChecked,
      List<ChatMedia>? medias,
      List<ChatMedia>? replyMedias,
      String? replyID,
      String? replyText,
      String? forwardText}) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      message: message ?? this.message,
      type: type ?? this.type,
      isGroupMessage: isGroupMessage ?? this.isGroupMessage,
      isEdited: isEdited ?? this.isEdited,
      sendTime: sendTime ?? this.sendTime,
      readTime: readTime ?? this.readTime,
      isChecked: isChecked ?? this.isChecked,
      medias: medias ?? this.medias,
      replyMedias: replyMedias ?? this.replyMedias,
      replyID: replyID ?? this.replyID,
      replyText: replyText ?? this.replyText,
      forwardText: forwardText ?? this.forwardText,
    );
  }

  @override
  bool operator ==(Object other) => other is Message && other.id == id;
}

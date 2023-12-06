import 'package:equatable/equatable.dart';
import 'message_model.dart';

class Chat extends Equatable {
  final List<Message> chats;

  const Chat({this.chats = const []});

  @override
  List<Object?> get props => [chats];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'chats': chats,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> map) => Chat(
        chats: map['chats'] ?? [],
      );

  Chat copyWith({List<Message>? chats}) {
    return Chat(
      chats: chats ?? this.chats,
    );
  }
}

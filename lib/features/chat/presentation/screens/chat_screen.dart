import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mplos_chat/shared/widgets/main_layout.dart';

import '../widgets/user_list.dart';
import '../widgets/chat_view.dart';

@RoutePage()
class ChatScreen extends ConsumerStatefulWidget {
  static const String routeName = 'ChatScreen';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return const MainLayout(
        child: Row(children: [UserList(), Expanded(child: ChatView())]));
  }
}

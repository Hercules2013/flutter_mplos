import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mplos_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:mplos_chat/features/chat/domain/providers/chat_provider.dart';
import 'package:mplos_chat/features/chat/presentation/providers/state/chat_notifier.dart';
import 'package:mplos_chat/features/chat/presentation/providers/state/chat_state.dart';

final chatStateNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final ChatRepository chatRepository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(chatRepository: chatRepository);
});

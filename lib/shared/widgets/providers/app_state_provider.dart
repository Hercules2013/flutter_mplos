import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:mplos_chat/shared/domain/repositories/layout_repository.dart';
// import 'package:mplos_chat/shared/domain/providers/app_provider.dart';
import 'package:mplos_chat/shared/widgets/providers/state/app_notifier.dart';
import 'package:mplos_chat/shared/widgets/providers/state/app_state.dart';

// final chatStateNotifierProvider =
//     StateNotifierProvider<ChatNotifier, ChatState>((ref) {
//   final ChatRepository chatRepository = ref.watch(chatRepositoryProvider);
//   return ChatNotifier(chatRepository: chatRepository);
// });

final appStateNotifierProvider =
    StateNotifierProvider<AppNotifier, AppState>((ref) {
  // final LayoutRepository layoutRepository = ref.watch(layoutRepositoryProvider);
  return AppNotifier();
});

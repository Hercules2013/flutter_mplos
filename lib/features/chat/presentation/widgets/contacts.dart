
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/chat/presentation/providers/chat_state_provider.dart';
import 'package:mplos_chat/features/chat/presentation/providers/state/chat_state.dart';
import 'package:mplos_chat/features/chat/presentation/widgets/user_item.dart';
import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/widgets/app_loading.dart';

class Contacts extends ConsumerStatefulWidget {
  final String filter;
  final String sortBy;
  const Contacts({Key? key, required this.filter, required this.sortBy})
      : super(key: key);

  @override
  ConsumerState<Contacts> createState() => _ContactsState();
}

class _ContactsState extends ConsumerState<Contacts> {
  late String filter;
  late String sortBy;
  final scrollController = ScrollController();
  bool isSearchActive = false;

  @override
  void initState() {
    super.initState();

    filter = widget.filter;
    sortBy = widget.sortBy;
    scrollController.addListener(scrollControllerListener);

    Future.delayed(Duration.zero, () {
      final notifier = ref.read(chatStateNotifierProvider.notifier);
      notifier.fetchUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void scrollControllerListener() {
    // if (scrollController.position.maxScrollExtent == scrollController.offset) {
    //   final notifier = ref.read(chatStateNotifierProvider.notifier);
    //   notifier.fetchUsers();
    // }
  }

  void refreshScrollControllerListener() {
    scrollController.removeListener(scrollControllerListener);
    scrollController.addListener(scrollControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatStateNotifierProvider);

    String filterText = state.filterOption;

    List<User> sortedUsers = [];
    for (var element in state.users) {
      sortedUsers.add(element);
    }

    sortedUsers.sort((user1, user2) {
      switch (state.sortOption) {
        case 'newest':
          return DateTime.parse(
                  user2.lastTime == 'null' ? '1970-00-00' : user2.lastTime)
              .difference(DateTime.parse(
                  user1.lastTime == 'null' ? '1970-00-00' : user1.lastTime))
              .inSeconds;
        case 'unread':
          return user2.unReadCount - user1.unReadCount;
        case 'name':
          return user1.name.toLowerCase().compareTo(user2.name.toLowerCase());
        default:
          return 0;
      }
    });

    return state.isLoadingUsers && state.users.isEmpty
        ? const AppLoading()
        : state.state == ChatConcreteState.failureUsers
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: () {
                          ref
                              .read(chatStateNotifierProvider.notifier)
                              .fetchUsers();
                        },
                        child: Text("Retry",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white))),
                    const SizedBox(height: 32),
                  ],
                ),
              )
            : Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    // thumbVisibility: MaterialStateProperty.all(true),
                    thumbColor: MaterialStateProperty.all(
                        AppColors.primary), // Replace with your desired color
                  ),
                ),
                child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        ...sortedUsers
                            .where((user) => user.name.contains(filterText))
                            .map((user) => UserItem(user))
                            .toList(),
                        state.isLoadingUsers
                            ? const AppLoading()
                            : const SizedBox.shrink()
                      ],
                    )),
              );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mplos_chat/features/chat/presentation/providers/chat_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';

import 'package:mplos_chat/shared/widgets/chat/avatar.dart';

enum MenuOption {
  toggleNotification,
  markAsRead,
  clearHistory,
  leaveChat,
  deleteGroup
}

// ignore: must_be_immutable
class UserItem extends ConsumerStatefulWidget {
  User user;
  UserItem(this.user, {super.key});

  @override
  ConsumerState<UserItem> createState() => _UserItemState();
}

class _UserItemState extends ConsumerState<UserItem> {
  User get user => widget.user;
  Color backColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatStateNotifierProvider);

    Widget? badgeWidget;
    Color badgeColor = AppColors.primary;
    if (user.isPinned) {
      badgeWidget = const Icon(Icons.push_pin, size: 14);
      badgeColor = AppColors.lightGrey;
    }
    if (user.isNotificationMuted) {
      badgeWidget = const Icon(Icons.notifications_off, size: 14);
      badgeColor = AppColors.lightGrey;
    }
    if (user.unReadCount > 0) {
      badgeWidget = Text(user.unReadCount.toString(),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.white));
    }

    return InkWell(
      onTap: () async {
        ref.read(chatStateNotifierProvider.notifier).setActiveUser(user);
        ref.read(chatStateNotifierProvider.notifier).fetchMessages();
      },
      splashColor: AppColors.extraLightGrey,
      onSecondaryTapDown: (detail) {
        ref.read(chatStateNotifierProvider.notifier).setActiveUser(user);
        ref.read(chatStateNotifierProvider.notifier).fetchMessages();
        showContextMenu(detail.globalPosition, context);
      },
      child: MouseRegion(
        // onEnter: (_) {
        //   setState(() {
        //     backColor = AppColors.extraLightGrey;
        //   });
        // },
        // onExit: (_) {
        //   setState(() {
        //     backColor = Colors.transparent;
        //   });
        // },
        cursor: SystemMouseCursors.click,
        child: Container(
          color: state.activeUser == user
              ? AppColors.extraLightGrey
              : Colors.transparent,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 6, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Avatar(user, 22, true),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 160,
                          child: Text(user.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 160,
                          child: Text(
                            user.lastMessage,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color(0xFF8B8B8B)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(minimizeTime(user.lastTime),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith()),
                    const SizedBox(height: 4),
                    badgeWidget == null
                        ? const SizedBox(height: 20)
                        : Badge(
                            label: badgeWidget,
                            padding:
                                const EdgeInsets.only(left: 6.0, right: 6.0),
                            backgroundColor: badgeColor,
                            largeSize: 20,
                          )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showContextMenu(Offset position, BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect positionBounds = RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    );

    var contextOptions = [
      {
        'text': !user.isNotificationMuted
            ? 'Disable Notification'
            : 'Enable Notification',
        'value': MenuOption.toggleNotification,
        'color': const Color(0xFF2E2A35)
      },
      {
        'text': 'Mark As Read',
        'value': MenuOption.markAsRead,
        'color': const Color(0xFF2E2A35)
      },
      {
        'text': 'Clear History',
        'value': MenuOption.clearHistory,
        'color': const Color(0xFF2E2A35)
      },
    ];

    if (user.type == "group") {
      contextOptions.add({
        'text': 'Leave Chat',
        'value': MenuOption.leaveChat,
        'color': const Color(0xFFFFB800)
      });
      if (user.isGroupAdmin == "yes") {
        contextOptions.add({
          'text': 'Delete Group',
          'value': MenuOption.deleteGroup,
          'color': const Color(0xFFFF3535)
        });
      }
    }

    final List<PopupMenuEntry<MenuOption>> items = contextOptions
        .map((item) => PopupMenuItem<MenuOption>(
            value: item['value'] as MenuOption,
            height: 36.0,
            child: Text(item['text'] as String,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: item['color'] as Color))))
        .toList();

    showMenu<MenuOption>(
            context: context,
            elevation: 8,
            // initialValue: MenuOption.option1,
            position: positionBounds,
            items: items,
            color: AppColors.white)
        .then((MenuOption? selectedValue) {
      if (selectedValue != null) {
        // Handle menu item selection here
        switch (selectedValue) {
          case MenuOption.toggleNotification:
            ref.read(chatStateNotifierProvider.notifier).toggleNotification();
            break;
          case MenuOption.markAsRead:
            ref.read(chatStateNotifierProvider.notifier).markAsRead();
            break;
          case MenuOption.clearHistory:
            ref.read(chatStateNotifierProvider.notifier).clearHistory();
            break;
          case MenuOption.leaveChat:
            ref.read(chatStateNotifierProvider.notifier).leaveChat();
            break;
          case MenuOption.deleteGroup:
            confirmDelete(() {
              ref.read(chatStateNotifierProvider.notifier).deleteGroup();
            });
            break;
        }
      }
    });
  }

  String minimizeTime(String time) {
    if (time.isEmpty || time == "null") return "";

    List<String> t = time.split(RegExp(r'[^0-9]'));
    DateTime dateTime = DateTime(int.parse(t[0]), int.parse(t[1]),
        int.parse(t[2]), int.parse(t[3]), int.parse(t[4]), int.parse(t[5]));
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 1) return "${t[2]}/${t[1]}/${t[0].substring(2)}";
    if (difference.inDays > 0) return "Yesterday";
    // if (difference.inHours > 0) return "";
    // if (difference.inMinutes > 0) return "";
    // if (difference.inSeconds > 0) return "${difference.inSeconds} sec ago";
    // return "Now";
    return "${t[3]}:${t[4]}";
  }

  void confirmDelete(callback) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shadowColor: AppColors.extraLightGrey,
            // Add your content for the modal here
            child: SizedBox(
                width: 320,
                height: 120,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                            "Are you sure you want to delete this group?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white)),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Cancel"),
                                  )),
                              const SizedBox(width: 24),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    callback();
                                    ref
                                        .read(
                                            chatStateNotifierProvider.notifier)
                                        .toggleChecking(false);
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Delete",
                                        style: TextStyle(color: Colors.white)),
                                  )),
                            ])
                      ]),
                )),
          );
        });
  }
}

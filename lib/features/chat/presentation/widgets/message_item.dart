import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

import 'package:mplos_chat/features/chat/presentation/providers/chat_state_provider.dart';
import 'package:mplos_chat/features/chat/presentation/providers/state/chat_state.dart';
import 'package:mplos_chat/features/chat/presentation/widgets/audio_slider.dart';
import 'package:mplos_chat/shared/domain/models/chat/message_model.dart';
import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/widgets/chat/avatar.dart';
import 'package:mplos_chat/shared/widgets/providers/app_state_provider.dart';

enum MenuOption {
  // createTask,
  reply,
  copyText,
  editMessage,
  forwardMessage,
  selectMessage
}

// ignore: must_be_immutable
class MessageItem extends ConsumerStatefulWidget {
  User peer;
  Message message;
  Function doAction;
  MessageItem(this.peer, this.message, this.doAction, {super.key});

  @override
  ConsumerState<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends ConsumerState<MessageItem> {
  User get peer => widget.peer;
  Message get message => widget.message;
  Function get doAction => widget.doAction;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateNotifierProvider);
    final chatState = ref.watch(chatStateNotifierProvider);

    // true if sent by peer, false if sent by me
    bool direction = message.sender != appState.userID;

    // read time for false, send time for true
    // List<String> t = (direction ? message.sendTime : message.readTime)
    //     .split(RegExp(r'[^0-9]'));
    // String readTime = t.length >= 6 ? "${t[3]}:${t[4]}" : "";
    List<String> t = message.sendTime.split(RegExp(r'[^0-9]'));
    String sendTime = t.length >= 6 ? "${t[3]}:${t[4]}" : "";

    bool isSelectingMessages =
        chatState.footerState == FooterConcreateState.select;

    return Container(
      decoration: isSelectingMessages && message.isChecked
          ? const BoxDecoration(
              color: Color(0x2500A0C3),
              border: Border(
                  left: BorderSide(color: AppColors.primary, width: 2.0)))
          : const BoxDecoration(),
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          isSelectingMessages
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Checkbox(
                      value: message.isChecked,
                      splashRadius: 0.0,
                      onChanged: (value) {
                        ref
                            .read(chatStateNotifierProvider.notifier)
                            .toggleCheck(message, value!);
                      },
                      fillColor: MaterialStateProperty.all(message.isChecked
                          ? AppColors.primary
                          : Colors.black38),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0))),
                )
              : const SizedBox.shrink(),
          Expanded(
            child: InkWell(
              splashColor: AppColors.extraLightGrey,
              onLongPress: () {},
              onSecondaryTapDown: (detail) {
                showContextMenu(detail.globalPosition, context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: direction
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    direction
                        ? Avatar(peer.copyWith(unReadCount: -1), 18, true)
                        : Container(),
                    const SizedBox(width: 8),
                    Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F7),
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 12, top: 12, right: 12, bottom: 8),
                            child: Column(
                                crossAxisAlignment: direction
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 500),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...message.medias.map((media) {
                                              if (media.type == 'image') {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Set the desired radius value
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Image(
                                                            width: 200,
                                                            image: NetworkImage(
                                                                media.url)),
                                                        IconButton(
                                                            onPressed: () {
                                                              downloadFile(
                                                                  media.url);
                                                            },
                                                            icon: const Icon(
                                                                Icons.download,
                                                                color: AppColors
                                                                    .primary))
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else if (media.type ==
                                                  'audio') {
                                                return AudioSlider(
                                                    media.url,
                                                    media.elapsed,
                                                    media.total,
                                                    media.isPlaying);
                                              } else {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons.file_present,
                                                        color:
                                                            AppColors.lightGrey,
                                                        size: 32),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 2.0),
                                                      child: SizedBox(
                                                        width: 150,
                                                        child: Text(
                                                            media.url
                                                                .split('\\')
                                                                .last
                                                                .split('/')
                                                                .last,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16)),
                                                      ),
                                                    ),
                                                    IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .file_download_outlined,
                                                            color: AppColors
                                                                .primary,
                                                            size: 32),
                                                        onPressed: () {
                                                          downloadFile(
                                                              media.url);
                                                        })
                                                  ],
                                                );
                                              }
                                            }),
                                            message.replyID != ''
                                                ? Container(
                                                    decoration: const BoxDecoration(
                                                        border: Border(
                                                            left: BorderSide(
                                                                color: AppColors
                                                                    .primary,
                                                                width: 4.0))),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0,
                                                            bottom: 4.0),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                              children: message
                                                                  .replyMedias
                                                                  .map((media) {
                                                            if (media.type ==
                                                                'image') {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10), // Set the desired radius value
                                                                  child: Image(
                                                                      width:
                                                                          200,
                                                                      image: NetworkImage(
                                                                          media
                                                                              .url)),
                                                                ),
                                                              );
                                                            } else if (media
                                                                    .type ==
                                                                'audio') {
                                                              return AudioSlider(
                                                                  media.url,
                                                                  media.elapsed,
                                                                  media.total,
                                                                  media
                                                                      .isPlaying);
                                                            } else {
                                                              return const SizedBox
                                                                  .shrink();
                                                            }
                                                          }).toList()),
                                                          message.replyText ==
                                                                  ''
                                                              ? const SizedBox
                                                                  .shrink()
                                                              : Text(
                                                                  message.replyText.substring(
                                                                      0,
                                                                      message.replyText.length <
                                                                              40
                                                                          ? message
                                                                              .replyText
                                                                              .length
                                                                          : 40),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          15)),
                                                        ]))
                                                : const SizedBox.shrink(),
                                            message.forwardText != ''
                                                ? const Icon(Icons.turn_right,
                                                    color: AppColors.lightGrey)
                                                : const SizedBox.shrink(),
                                            Text(
                                                HtmlUnescape()
                                                    .convert(message.message),
                                                style: const TextStyle(
                                                    fontSize: 16)),
                                          ])),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      message.isEdited == true
                                          ? const Icon(Icons.edit,
                                              color: AppColors.primary,
                                              size: 16)
                                          : const SizedBox.shrink(),
                                      !direction
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4.0),
                                              child: () {
                                                if (message.sendTime ==
                                                    "undefined") {
                                                  return const Icon(Icons.done,
                                                      color:
                                                          AppColors.lightGrey);
                                                } else if (message.sendTime !=
                                                        "" &&
                                                    message.readTime != "") {
                                                  return const Icon(
                                                      Icons.done_all,
                                                      color: AppColors.primary,
                                                      size: 16);
                                                } else if (message.readTime ==
                                                    "") {
                                                  return const Icon(Icons.done,
                                                      color: AppColors.primary,
                                                      size: 16);
                                                }
                                                return const SizedBox.shrink();
                                              }(),
                                            )
                                          : const SizedBox.shrink(),
                                      Text(sendTime,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.lightGrey)),
                                    ],
                                  )
                                ]))),
                  ],
                ),
              ),
            ),
          )
        ],
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

    final appState = ref.read(appStateNotifierProvider);

    List<dynamic> contextOptions = [
      // {
      //   'text': 'Create Task',
      //   'value': MenuOption.createTask,
      // },
      {
        'text': 'Reply',
        'value': MenuOption.reply,
      },
    ];

    if (message.medias.isEmpty) {
      contextOptions.addAll([
        {
          'text': 'Copy Text',
          'value': MenuOption.copyText,
        },
      ]);

      if (message.sender == appState.userID) {
        contextOptions.add({
          'text': 'Edit Message',
          'value': MenuOption.editMessage,
        });
      }
    }

    contextOptions.addAll([
      {
        'text': 'Forward Message',
        'value': MenuOption.forwardMessage,
      },
      {
        'text': 'Select Message',
        'value': MenuOption.selectMessage,
      },
    ]);

    final List<PopupMenuEntry<MenuOption>> items = contextOptions
        .map((item) => PopupMenuItem<MenuOption>(
            value: item['value'] as MenuOption,
            height: 36.0,
            child: Text(item['text'] as String,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2E2A35)))))
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
          // case MenuOption.createTask:
          //   break;
          case MenuOption.reply:
            doAction('reply');
            break;
          case MenuOption.copyText:
            Clipboard.setData(ClipboardData(text: message.message));
            break;
          case MenuOption.editMessage:
            doAction('edit');
            break;
          case MenuOption.forwardMessage:
            doAction('forward');
            break;
          case MenuOption.selectMessage:
            if (ref.read(chatStateNotifierProvider).footerState !=
                FooterConcreateState.select) {
              ref.read(chatStateNotifierProvider.notifier).toggleChecking(true);
            }
            ref
                .read(chatStateNotifierProvider.notifier)
                .toggleCheck(message, true);
            break;
        }
      }
    });
  }

  Future<void> downloadFile(String url) async {
    Directory folder = Directory('./downloads');
    bool folderExists = folder.existsSync();
    if (!folderExists) folder.createSync(recursive: true);

    String? filePath = await FilePicker.platform.getDirectoryPath();

    // String? filePath = await FilePicker.platform.saveFile(
    //     dialogTitle: 'Please select an output file: ',
    //     fileName: url.split('/').last);

    if (filePath != null) {
      log("Downloading from $url to $filePath/${url.split('/').last}");
      final response = await http.get(Uri.parse(url));
      final file = File('$filePath/${url.split('/').last}');
      await file.writeAsBytes(response.bodyBytes);
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' show min, Random;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mplos_chat/features/chat/presentation/providers/state/chat_state.dart';
import 'package:mplos_chat/features/chat/presentation/widgets/audio_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:record/record.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:mplos_chat/features/chat/presentation/providers/chat_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/chat/message_model.dart';
import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/widgets/app_loading.dart';
import 'package:mplos_chat/shared/widgets/chat/avatar.dart';
import 'package:mplos_chat/shared/widgets/providers/app_state_provider.dart';
import 'package:mplos_chat/features/chat/presentation/widgets/message_item.dart';

enum ChatMenuOption { deleteChat, toggleNotification, leaveChat, cleanHistory }

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  ScrollController scrollController = ScrollController();
  TextEditingController inputController = TextEditingController();
  List<User> tagUsers = [];
  Message? editMsg;
  double inputHeight = 40;
  final record = Record();
  Timer? recordTimer;
  DateTime recordStartTime = DateTime.now();
  String recordTime = "00:00";
  double recordPercent = 0.0;
  bool isEmjoiShowed = false, isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    // All life-cycles of ChatView
    scrollController.addListener(scrollControllerListener);
  }

  void scrollControllerListener() {
    if (scrollController.position.minScrollExtent == scrollController.offset) {
      final notifier = ref.read(chatStateNotifierProvider.notifier);
      notifier.fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateNotifierProvider);
    final chatState = ref.watch(chatStateNotifierProvider);
    User? user = chatState.activeUser;
    List<Widget> msgWidgets = [];

    Message? replyMsg = chatState.replyID == ''
        ? null
        : chatState.messages
            .where((element) => element.id == chatState.replyID)
            .first;

    for (int i = 0; i < chatState.messages.length; ++i) {
      Message msg = chatState.messages[i];
      if (i != 0 &&
          msg.sendTime.substring(0, 10) !=
              chatState.messages[i - 1].sendTime.substring(0, 10)) {
        msgWidgets.add(Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Stack(alignment: AlignmentDirectional.center, children: [
              const Divider(
                color: AppColors.lightGrey,
                thickness: 0.5,
              ),
              Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(minimizeDate(msg.sendTime),
                      style: const TextStyle(color: AppColors.lightGrey)))
            ])));
      }
      msgWidgets
          .add(MessageItem(user!, msg, (type) => handleMsgAction(type, msg)));
    }

    String statusText = '';
    if (user != null) {
      switch (user.status) {
        case Status.away:
          statusText = 'Away';
          break;
        case Status.offline:
          statusText = 'Offline';
          break;
        case Status.onbreak:
          statusText = 'On Break';
          break;
        case Status.oncall:
          statusText = 'On Call';
          break;
        case Status.online:
          statusText = 'Online';
          break;
        default:
          break;
      }
    }

    Widget footerWidget;

    bool isRemovable = chatState.selectedMessages
        .where((msg) => msg.sender != appState.userID)
        .isEmpty;

    String replyText = replyMsg == null
        ? ''
        : (replyMsg.message.isNotEmpty
            ? HtmlUnescape().convert(replyMsg.message)
            : "File: ${replyMsg.medias.first.url}");

    if (chatState.activeUser != null && chatState.gotNewMessage) {
      scrollToBottom();
    }

    switch (chatState.footerState) {
      case FooterConcreateState.normal:
        footerWidget = Column(children: [
          Container(
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppColors.extraLightGrey),
                    bottom: BorderSide(color: AppColors.extraLightGrey)),
              ),
              height: tagUsers.length > 4 ? 200.0 : 50.0 * tagUsers.length,
              child: ListView(
                  children: tagUsers
                      .map((user) => InkWell(
                            onTap: () {
                              completeName(user.name);
                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2.0),
                                child: Row(children: [
                                  Avatar(user, 18, true),
                                  const SizedBox(width: 8.0),
                                  Text(user.name,
                                      style: const TextStyle(fontSize: 18)),
                                ])),
                          ))
                      .toList())),
          replyMsg != null
              ? Container(
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          left: BorderSide(color: Colors.red, width: 2.0))),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 0, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  children: replyMsg.medias.map((media) {
                                if (media.type == 'image') {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          10), // Set the desired radius value
                                      child: Image(
                                          width: 200,
                                          image: NetworkImage(media.url)),
                                    ),
                                  );
                                } else if (media.type == 'audio') {
                                  return AudioSlider(media.url, media.elapsed,
                                      media.total, media.isPlaying);
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }).toList()),
                              Text(
                                  replyText.substring(
                                      0,
                                      replyText.length < 40
                                          ? replyText.length
                                          : 40),
                                  style: const TextStyle(fontSize: 15)),
                            ]),
                        IconButton(
                            onPressed: () {
                              replyMessage(null);
                            },
                            icon: const Icon(Icons.close,
                                color: AppColors.lightGrey))
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          isEmjoiShowed
              ? SizedBox(
                  height: 150,
                  child: EmojiPicker(
                    // onEmojiSelected: (Category category, Emoji emoji) {
                    //   // Do something when emoji is tapped (optional)
                    // },
                    onBackspacePressed: () {
                      // Do something when the user taps the backspace button (optional)
                      // Set it to null to hide the Backspace-Button
                    },
                    textEditingController:
                        inputController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                    config: const Config(
                        columns: 15,
                        emojiSizeMax: 32.0,
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                        initCategory: Category.RECENT,
                        bgColor: Color(0xFFF2F2F2),
                        indicatorColor: Colors.blue,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.blue,
                        backspaceColor: Colors.blue,
                        skinToneDialogBgColor: Colors.white,
                        skinToneIndicatorColor: Colors.grey,
                        enableSkinTones: true,
                        recentTabBehavior: RecentTabBehavior.RECENT,
                        recentsLimit: 28,
                        noRecents: Text(
                          'No Recents',
                          style:
                              TextStyle(fontSize: 20, color: AppColors.primary),
                          textAlign: TextAlign.center,
                        ), // Needs to be const Widget
                        loadingIndicator: Center(
                            child:
                                CircularProgressIndicator()), // Needs to be const Widget
                        tabIndicatorAnimDuration: kTabScrollDuration,
                        categoryIcons: CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL),
                  ))
              : const SizedBox.shrink(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: AppColors.extraLightGrey))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: IconButton(
                    onPressed: sendFile,
                    icon: const Icon(Icons.attach_file,
                        color: AppColors.lightGrey)),
              ),
              Expanded(
                  child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: inputHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) {
                      setState(() {
                        isShiftPressed = event.isShiftPressed;
                      });
                    },
                    child: TextField(
                        controller: inputController,
                        onChanged: handleMessageChange,
                        onSubmitted: (value) {
                          if (!isShiftPressed) {
                            inputController.text = inputController.text
                                .substring(0, inputController.text.length - 1);
                            sendText();
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Type your message here..',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.lightGrey, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0)),
                        style: GoogleFonts.roboto(fontSize: 14.0),
                        minLines: null,
                        maxLines: null,
                        textInputAction: TextInputAction.none,
                        keyboardType: TextInputType.multiline,
                        expands: true),
                  ),
                ),
              )),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
              //   child: IconButton(
              //       onPressed: () {
              //         setState(() {
              //           isEmjoiShowed = !isEmjoiShowed;
              //         });
              //       },
              //       icon: Icon(Icons.emoji_emotions_outlined,
              //           color: isEmjoiShowed
              //               ? AppColors.primary
              //               : AppColors.lightGrey)),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    onPressed: () {
                      if (inputController.text.isEmpty) {
                        startRecording();
                      } else {
                        sendText();
                      }
                    },
                    icon: Icon(
                        inputController.text.isNotEmpty
                            ? Icons.send
                            : Icons.mic_outlined,
                        color: inputController.text.isNotEmpty
                            ? AppColors.primary
                            : AppColors.lightGrey)),
              )
            ]),
          )
        ]);
        break;
      case FooterConcreateState.select:
        footerWidget = Container(
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: AppColors.extraLightGrey))),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () {
                        ref
                            .read(chatStateNotifierProvider.notifier)
                            .toggleChecking(false);
                      },
                      icon:
                          const Icon(Icons.close, color: AppColors.lightGrey)),
                ),
                Expanded(
                    child: Text(
                        "${chatState.selectedMessages.length} Message${chatState.selectedMessages.length < 2 ? '' : 's'} Selected",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15))),
                isRemovable
                    ? IconButton(
                        onPressed: () {
                          confirmDelete(removeMessages);
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey))
                    : const SizedBox.shrink(),
                IconButton(
                    onPressed: () {
                      forwardMessages(
                          ref.read(chatStateNotifierProvider).selectedMessages);
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.grey))
              ]),
            ));
        break;
      case FooterConcreateState.record:
        footerWidget = Container(
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: AppColors.extraLightGrey))),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () {
                        stopRecording(false);
                      },
                      icon:
                          const Icon(Icons.close, color: AppColors.lightGrey)),
                ),
                Expanded(
                    child: LinearProgressIndicator(
                        value: recordPercent,
                        minHeight: 10,
                        backgroundColor: AppColors.lightGrey,
                        color: AppColors.primary)),
                const SizedBox(width: 16.0),
                Text(recordTime),
                IconButton(
                    onPressed: () {
                      stopRecording(true);
                    },
                    icon: const Icon(Icons.send, color: AppColors.primary))
              ]),
            ));
        break;
      default:
        footerWidget = const SizedBox.shrink();
        break;
    }

    return Center(
      child: user == null
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(
                Icons.chat_rounded,
                color: AppColors.primary,
                size: 60,
              ),
              Text("Start a Chat",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w400))
            ])
          : Column(children: [
              Container(
                decoration: const BoxDecoration(
                  // color: AppColors.white,
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.extraLightGrey, width: 1)),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(0.5),
                  //     spreadRadius: 2,
                  //     blurRadius: 4,
                  //     offset: Offset(0, 2),
                  //   ),
                  // ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Avatar(chatState.activeUser!, 22, true),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(statusText,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF000000)))
                            ],
                          )
                        ]),
                        Row(children: [
                          IconButton(
                              onPressed: callVideo,
                              icon: const Icon(Icons.videocam_outlined,
                                  color: AppColors.primary)),
                          IconButton(
                              onPressed: callAudio,
                              icon: const Icon(Icons.call,
                                  color: AppColors.primary)),
                          IconButton(
                              onPressed: showChatMenu,
                              icon: const Icon(Icons.more_vert,
                                  color: AppColors.lightGrey)),
                        ])
                      ]),
                ),
              ),
              Expanded(
                  child: Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    // thumbVisibility: MaterialStateProperty.all(true),
                    thumbColor: MaterialStateProperty.all(
                        AppColors.primary), // Replace with your desired color
                  ),
                ),
                child: chatState.isLoadingMessages && chatState.messages.isEmpty
                    ? const AppLoading()
                    : SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            chatState.isLoadingMessages
                                ? const AppLoading()
                                : const SizedBox.shrink(),
                            ...msgWidgets,
                            const SizedBox(height: 24)
                          ],
                        ),
                      ),
              )),
              footerWidget
            ]),
    );
  }

  callVideo() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    String url =
        "https://${ref.read(appStateNotifierProvider).companyName}.mplos.com/mission/chat_video_call";
    url +=
        "?=cursor=${base64Encode(ref.read(appStateNotifierProvider).userName.codeUnits)}";
    url +=
        "&uid=${base64Encode(ref.read(chatStateNotifierProvider).activeUser!.id.toString().codeUnits)}";
    url +=
        "&uname=${base64Encode(ref.read(chatStateNotifierProvider).activeUser!.name.toString().codeUnits)}";
    url +=
        "&useridcurrent=${base64Encode(ref.read(appStateNotifierProvider).userID.codeUnits)}";
    url +=
        "&meetingid=${Iterable.generate(6, (idx) => chars[random.nextInt(chars.length)]).join()}";
    url += "&calltype=send";
    launchUrl(Uri.parse(url));
  }

  callAudio() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    String url =
        "https://${ref.read(appStateNotifierProvider).companyName}.mplos.com/mission/chat_audio_call";
    url +=
        "?=cursor=${base64Encode(ref.read(appStateNotifierProvider).userName.codeUnits)}";
    url +=
        "&uid=${base64Encode(ref.read(chatStateNotifierProvider).activeUser!.id.toString().codeUnits)}";
    url +=
        "&uname=${base64Encode(ref.read(chatStateNotifierProvider).activeUser!.name.toString().codeUnits)}";
    url +=
        "&useridcurrent=${base64Encode(ref.read(appStateNotifierProvider).userID.codeUnits)}";
    url +=
        "&meetingid=${Iterable.generate(6, (idx) => chars[random.nextInt(chars.length)]).join()}";
    url += "&calltype=send";
    launchUrl(Uri.parse(url));
  }

  showChatMenu() {
    Offset position = const Offset(1200, 110);
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect positionBounds = RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    );

    final chatState = ref.watch(chatStateNotifierProvider);
    User? activeUser = chatState.activeUser;

    bool isDisabledNotification = activeUser!.isNotificationMuted;

    var contextOptions = [
      {
        'text': 'Delete Chat',
        'value': ChatMenuOption.deleteChat,
      },
      {
        'text': '${isDisabledNotification ? 'Enable' : 'Disable'} Notification',
        'value': ChatMenuOption.toggleNotification,
      },
      {
        'text': 'Clean History',
        'value': ChatMenuOption.cleanHistory,
      },
    ];

    if (activeUser.type == "group") {
      contextOptions.insert(2, {
        'text': 'Leave Chat',
        'value': ChatMenuOption.leaveChat,
      });
    }

    final List<PopupMenuEntry<ChatMenuOption>> items = contextOptions
        .map((item) => PopupMenuItem<ChatMenuOption>(
            value: item['value'] as ChatMenuOption,
            height: 36.0,
            child: Text(item['text'] as String,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2E2A35)))))
        .toList();

    showMenu<ChatMenuOption>(
            context: context,
            elevation: 8,
            // initialValue: ChatMenuOption.option1,
            position: positionBounds,
            items: items,
            color: AppColors.white)
        .then((ChatMenuOption? selectedValue) {
      if (selectedValue != null) {
        // Handle menu item selection here
        switch (selectedValue) {
          case ChatMenuOption.deleteChat:
            confirmDelete(() {
              ref.read(chatStateNotifierProvider.notifier).deleteGroup();
            });
            break;
          case ChatMenuOption.toggleNotification:
            ref.read(chatStateNotifierProvider.notifier).toggleNotification();
            break;
          case ChatMenuOption.leaveChat:
            ref.read(chatStateNotifierProvider.notifier).leaveChat();
            break;
          case ChatMenuOption.cleanHistory:
            ref.read(chatStateNotifierProvider.notifier).toggleChecking(false);
            ref.read(chatStateNotifierProvider.notifier).clearHistory();
            break;
        }
      }
    });
  }

  scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      ref.read(chatStateNotifierProvider.notifier).scrollToNewMessage();
    });
  }

  String minimizeDate(String time) {
    List<String> t = time.split(RegExp(r'[^0-9]'));
    DateTime dateTime = DateTime(int.parse(t[0]), int.parse(t[1]),
        int.parse(t[2]), int.parse(t[3]), int.parse(t[4]), int.parse(t[5]));
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 1) return "${t[2]}/${t[1]}/${t[0]}";
    if (difference.inDays > 0) return "Yesterday";
    return "Today";
  }

  void handleMsgAction(type, message) {
    switch (type.toString()) {
      case 'reply':
        replyMessage(message);
        break;
      case 'forward':
        forwardMessages([message]);
        break;
      case 'edit':
        editMessage(message);
        break;
      case 'remove':
        confirmDelete(() {
          removeMessage(message);
        });
        break;
      default:
        break;
    }
  }

  sendText() {
    setState(() {
      inputHeight = 40;
    });

    final text = inputController.text;
    if (text.isEmpty) {
      return;
    }
    inputController.clear();

    final chatState = ref.read(chatStateNotifierProvider);
    Message? replyMsg = chatState.replyID == ''
        ? null
        : chatState.messages
            .where((element) => element.id == chatState.replyID)
            .first;

    if (editMsg != null) {
      ref.read(chatStateNotifierProvider.notifier).editMessage(editMsg!, text);
    } else {
      ref.read(chatStateNotifierProvider.notifier).sendMessage(
          Message(
              sender: ref.read(appStateNotifierProvider).userID,
              receiver: ref.read(chatStateNotifierProvider).activeUser!.id,
              message: text,
              sendTime: DateTime.now().toString(),
              // readTime: DateTime.now().toString(),
              replyID: ref.read(chatStateNotifierProvider).replyID,
              replyText: replyMsg != null ? replyMsg.message : "",
              replyMedias: replyMsg != null ? replyMsg.medias : []),
          ref.read(chatStateNotifierProvider).replyID);
    }

    replyMessage(null);
    editMsg = null;
    scrollToBottom();
  }

  sendFile() async {
    FilePickerResult? files = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        lockParentWindow: true,
        type: FileType.custom,
        allowedExtensions: [
          "WEBM",
          "webm",
          "AVI",
          "avif",
          "AVIF",
          "avi",
          "MKV",
          "mkv",
          "3GP",
          "3gp",
          "3gpp",
          "3Gpp",
          "ogg",
          "OGG",
          "oga",
          "OGA",
          "html",
          "doc",
          "docx",
          "gif",
          "jpg",
          "jpeg",
          "mpg",
          "mp4",
          "mp3",
          "odt",
          "odp",
          "ods",
          "pdf",
          "ppt",
          "pptx",
          "tif",
          "tiff",
          "txt",
          "xls",
          "xlsx",
          "wav",
          "png",
          "csv",
          "aspx",
          "zip",
          "HTML",
          "DOC",
          "DOCX",
          "GIF",
          "JPG",
          "JPEG",
          "MPG",
          "MP4",
          "MP3",
          "ODT",
          "ODP",
          "ODS",
          "PDF",
          "PPT",
          "PPTX",
          "TIF",
          "TIFF",
          "TXT",
          "XLS",
          "XLSX",
          "WAV",
          "PNG",
          "CSV",
          "ASPX",
          "ZIP",
          "JFIF",
          "jfif"
        ]);
    if (files == null) return;

    final appState = ref.read(appStateNotifierProvider);
    final chatState = ref.read(chatStateNotifierProvider);

    for (var file in files.files) {
      log("path: ${file.path!}, name: ${file.name}");
      String type = "unknown";
      type = file.path!.endsWith('jpg') || file.path!.endsWith('png')
          ? "image"
          : type;
      type = file.path!.endsWith('mp3') || file.path!.endsWith('wav')
          ? "audio"
          : type;
      ref.read(chatStateNotifierProvider.notifier).sendFile(Message(
          sender: appState.userID,
          receiver: chatState.activeUser!.id,
          isGroupMessage: chatState.activeUser!.type != "user",
          sendTime: DateTime.now().toString(),
          medias: [ChatMedia(url: file.path!, type: type)]));
    }
  }

  void replyMessage(Message? message) {
    // setState(() {
    //   replyMsg = message;
    // });
    if (message == null) {
      ref.read(chatStateNotifierProvider.notifier).setReplyMessage("");
    } else {
      ref.read(chatStateNotifierProvider.notifier).setReplyMessage(message.id);
    }
  }

  void editMessage(Message message) {
    inputController.text = message.message;
    editMsg = message;
  }

  void forwardMessages(List<Message> messages) {
    final chatState = ref.read(chatStateNotifierProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchText = "";
        List<User> forwardUsers = [];

        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          List<User> filteredUsers = chatState.users
              .where((user) => user.type == 'user')
              .where((user) =>
                  user.name.toLowerCase().contains(searchText.toLowerCase()))
              .where((user) => user != chatState.activeUser!)
              .where((user) => forwardUsers.contains(user) == false)
              .toList();
          return Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  // thumbVisibility: MaterialStateProperty.all(true),
                  thumbColor: MaterialStateProperty.all(
                      AppColors.primary), // Replace with your desired color
                ),
              ),
              child: Dialog(
                  backgroundColor: Colors.white,
                  shadowColor: AppColors.extraLightGrey,
                  // Add your content for the modal here
                  child: SizedBox(
                    width: 500,
                    height: 640,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            color: AppColors.primary,
                            width: 500,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: const Text("Forward message",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, color: AppColors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 18, top: 18, right: 18),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text("Choose Users",
                                      textAlign: TextAlign.left),
                                  const SizedBox(height: 12),
                                  SearchBar(
                                      constraints: const BoxConstraints(
                                        maxWidth: 450,
                                        maxHeight: 40,
                                      ),
                                      padding: const MaterialStatePropertyAll(
                                          EdgeInsets.only(
                                              left: 10, bottom: 4.5)),
                                      elevation:
                                          const MaterialStatePropertyAll(0),
                                      shape: const MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: AppColors.lightGrey,
                                                  width: 2.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)))),
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Color(0xffffffff)),
                                      leading: const Padding(
                                        padding:
                                            EdgeInsets.only(left: 12, top: 4),
                                        child: Icon(Icons.search,
                                            color: Color(0xff868688), size: 18),
                                      ),
                                      hintText: "Search User",
                                      hintStyle: MaterialStatePropertyAll(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                color: const Color(0x73000000)),
                                      ),
                                      textStyle: MaterialStatePropertyAll(
                                          Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(color: Colors.black)),
                                      onChanged: (value) {
                                        setState(() {
                                          searchText = value;
                                        });
                                      }),
                                  const SizedBox(height: 12)
                                ]),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: forwardUsers.length * 50 < 200
                                    ? forwardUsers.length * 50
                                    : 200,
                                minHeight: 0),
                            child: ListView(
                                children: forwardUsers
                                    .map((user) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 36.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Avatar(
                                                    user.copyWith(
                                                        unReadCount: -1),
                                                    15,
                                                    true),
                                                Text(user.name),
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        forwardUsers.removeAt(
                                                            forwardUsers
                                                                .indexOf(user));
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.close,
                                                        color:
                                                            AppColors.primary))
                                              ]),
                                        ))
                                    .toList()),
                          ),
                          const Divider(color: Colors.black, thickness: 0.5),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 32.0, right: 32.0),
                                child: filteredUsers.isEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            const SizedBox(height: 40),
                                            const Icon(
                                              Icons.no_accounts_outlined,
                                              color: AppColors.primary,
                                              size: 60,
                                            ),
                                            Text("No more users",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.copyWith(
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w400))
                                          ])
                                    : Column(
                                        children: filteredUsers
                                            .map((user) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Avatar(user, 24, true),
                                                        Text(user.name),
                                                        IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                forwardUsers
                                                                    .add(user);
                                                              });
                                                            },
                                                            icon: const Icon(
                                                                Icons.add,
                                                                color: AppColors
                                                                    .primary))
                                                      ]),
                                                ))
                                            .toList()),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  for (var user in forwardUsers) {
                                    for (var message in messages) {
                                      ref
                                          .read(chatStateNotifierProvider
                                              .notifier)
                                          .forwardMessage(user.id, message.id);
                                    }
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 8.0),
                                  child: Text("Forward",
                                      style: TextStyle(color: Colors.white)),
                                )),
                          )
                        ]),
                  )));
        });
      },
    );
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
                            "Are you sure you want to delete these messages?",
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

  void removeMessages() {
    List<Message> messages =
        ref.read(chatStateNotifierProvider).selectedMessages;
    for (var message in messages) {
      removeMessage(message);
    }
  }

  void removeMessage(Message message) {
    ref.read(chatStateNotifierProvider.notifier).removeMessage(message);
  }

  void handleMessageChange(value) {
    setState(() {
      inputHeight = min(25 + value.toString().split('\n').length * 15, 85);
    });

    int lastAt = value.toString().lastIndexOf('@');
    if (lastAt == -1) {
      tagUsers = [];
    } else {
      String name = value.toString().substring(lastAt + 1);

      final chatState = ref.read(chatStateNotifierProvider);
      setState(() {
        tagUsers = chatState.users
            .where(
                (user) => user.name.toUpperCase().contains(name.toUpperCase()))
            .toList();
      });
    }
  }

  void completeName(value) {
    int lastAt = inputController.text.toString().lastIndexOf('@');
    if (lastAt == -1) return;

    inputController.text =
        inputController.text.substring(0, lastAt + 1) + value;
  }

  void startRecording() async {
    ref.read(chatStateNotifierProvider.notifier).toggleRecording(true);

    if (await record.hasPermission()) {
      await record.start(
          path: 'record.wav',
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          samplingRate: 44100);
      recordStartTime = DateTime.now();
      recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          Duration diff = DateTime.now().difference(recordStartTime);
          recordPercent = (diff.inMinutes * 60 + diff.inSeconds) / (3 * 60);
          recordTime =
              '${diff.inMinutes.toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      });
    }
  }

  void stopRecording(bool isSend) async {
    ref.read(chatStateNotifierProvider.notifier).toggleRecording(false);

    recordTimer?.cancel();
    recordTimer = null;
    recordTime = "00:00";
    String? recordFilePath = await record.stop();
    if (isSend) {
      // ref.read(chatStateNotifierProvider.notifier).sendFile(recordFilePath!,
      //     ref.read(chatStateNotifierProvider).activeUser!.id, "no");
      ref.read(chatStateNotifierProvider.notifier).sendFile(Message(
          sender: ref.read(appStateNotifierProvider).userID,
          receiver: ref.read(chatStateNotifierProvider).activeUser!.id,
          isGroupMessage:
              ref.read(chatStateNotifierProvider).activeUser!.type != "user",
          sendTime: DateTime.now().toString(),
          medias: [ChatMedia(url: recordFilePath!, type: 'audio')]));
    }
  }
}

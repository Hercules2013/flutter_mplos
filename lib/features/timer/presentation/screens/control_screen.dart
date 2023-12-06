import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';

import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/widgets/providers/app_state_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_manager/window_manager.dart';
import 'package:watcher/watcher.dart';

// import 'package:local_notifier/local_notifier.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@RoutePage()
class ControlScreen extends ConsumerStatefulWidget {
  static const String routeName = 'ControlScreen';

  const ControlScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends ConsumerState<ControlScreen> {
  TextEditingController taskController = TextEditingController();
  List<DropdownMenuEntry> missions = [];

  late WindowController menuWnd, taskWnd, timeWnd, chatWnd;
  String curVisible = 'none';

  late Timer timer;
  late WebSocketChannel webSocket;

  final audioPlayer = AudioPlayer();
  String activeURL = '';

  bool isScreenshot = false, isScreenRecord = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      WindowManager.instance.setSize(const Size(520, 50));
      WindowManager.instance.setAlignment(Alignment.bottomRight);
    });

    final timerState = ref.read(timerStateNotifierProvider);

    // Initializing Sub Windows ...
    WidgetsFlutterBinding.ensureInitialized();

    log('******** initialize *********');
    log(timerState.token);
    log(timerState.activeCompany.toString());

    String optionData = jsonEncode({
      "type": "Menu",
      "token": timerState.token,
      "companies": timerState.companies,
      "activeCompany": timerState.activeCompany,
      "userStatus": timerState.userStatus,
      "startWorkTime": timerState.startWorkTime,
      "lastTask": timerState.lastTask
    });
    DesktopMultiWindow.createWindow(optionData)
        .then((value) => menuWnd = value);

    String taskData = jsonEncode({
      "type": "Taskbar",
      "token": timerState.token,
      "activeCompany": timerState.activeCompany,
      "activeTask": timerState.activeTask ?? 'null',
      "tasks": timerState.tasks,
      "progress": timerState.progress,
      "progressColor": timerState.progressColor
    });
    DesktopMultiWindow.createWindow(taskData).then((value) => taskWnd = value);

    String timeData = jsonEncode({
      "type": "Timer",
      "token": timerState.token,
      "activeCompany": timerState.activeCompany,
      "timerStatus": timerState.timerStatus
    });
    DesktopMultiWindow.createWindow(timeData).then((value) => timeWnd = value);

    String chatData = jsonEncode({
      "type": "Chat",
      "token": timerState.token,
      "activeCompany": timerState.activeCompany,
      "companies": timerState.companies,
      "activeTask": timerState.activeTask ?? 'null',
      "tasks": timerState.tasks,
      "workTime": dur2str(timerState.workTime),
      "userStatus": timerState.userStatus,
      "timerStatus": timerState.timerStatus,
    });
    DesktopMultiWindow.createWindow(chatData).then((value) => chatWnd = value);

    // Initializing WebSocket Client ...
    Future.delayed(Duration.zero, () async {
      ref
          .read(appStateNotifierProvider.notifier)
          .setUserName(ref.read(timerStateNotifierProvider).username);
      ref.read(appStateNotifierProvider.notifier).setCompanyID(
          ref.read(timerStateNotifierProvider).activeCompany.id.toString());
      ref.read(appStateNotifierProvider.notifier).setCompanyName(
          ref.read(timerStateNotifierProvider).activeCompany.name);
    });

    // Interval function
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final timerState = ref.read(timerStateNotifierProvider);
      if (timerState.timerStatus == 'active') {
        ref.read(timerStateNotifierProvider.notifier).increaseTaskTime();

        Duration workTime = ref.read(timerStateNotifierProvider).workTime;
        if (taskWnd.windowId != -1) {
          DesktopMultiWindow.invokeMethod(taskWnd.windowId, 'root_event',
              jsonEncode({'type': 'timer', 'duration': dur2str(workTime)}));
        }
        if (chatWnd.windowId != -1) {
          DesktopMultiWindow.invokeMethod(chatWnd.windowId, 'root_event',
              jsonEncode({'type': 'timer', 'duration': dur2str(workTime)}));
        }
      }
    });

    DesktopMultiWindow.setMethodHandler(_handleMethodCallback);

    // WebSocket Configuration
    String webSocketURL =
        'wss://socket.xite.io:9006/?id=${timerState.activeCompany.name}-desktop-${timerState.activeCompany.userID}-';
    HttpOverrides.global = MyHttpOverrides();
    WebSocketChannel webSocket =
        WebSocketChannel.connect(Uri.parse(webSocketURL), protocols: {});

    log('Initializing websocket :: $webSocketURL');

    webSocket.stream.handleError((error) {
      if (error is WebSocketChannelException) {
        // WebSocketChannelException contains the reason for the error
        log('Error: ${error.message}');
      } else {
        // Handle other types of errors here
        log('Unknown error occurred');
      }
    });

    webSocket.stream.listen((event) async {
      final message = event.toString();

      log('********* websocket **********');
      log(message);

      // Broadcast WS events to all sub windows and main window
      final subWindowIDs = await DesktopMultiWindow.getAllSubWindowIds();
      for (final windowId in subWindowIDs) {
        if (windowId == -1) continue;
        DesktopMultiWindow.invokeMethod(
          windowId,
          'ws_event',
          message,
        );
      }
      DesktopMultiWindow.invokeMethod(0, 'ws_event', message);
    });

    // Process

    Future.delayed(Duration.zero, () async {
      Directory javaDirectory = await getApplicationDocumentsDirectory();
      String javaDirPath =
          '${javaDirectory.path.replaceAll('Documents', 'mplos')}\\${timerState.activeCompany.userID}\\${timerState.activeCompany.id}';
      log('Watching $javaDirPath');
      DirectoryWatcher(javaDirPath).events.listen((event) {
        switch (event.type) {
          case ChangeType.ADD:
            if (event.path.endsWith('.jpg')) {
              sendScreenshot(event.path);
            }
            break;
          case ChangeType.REMOVE:
            break;
          case ChangeType.MODIFY:
            break;
        }
        log(event.toString());
      });

      FileWatcher(
              '${javaDirectory.path.replaceAll('Documents', 'mplos')}\\apps.cnf')
          .events
          .listen((event) {
        if (event.type != ChangeType.REMOVE && chatWnd.windowId != -1) {
          File file = File(event.path);
          if (!file.existsSync()) return;

          String content = file.readAsStringSync();
          if (content.isEmpty) return;

          final jsonData = jsonDecode(content);
          DesktopMultiWindow.invokeMethod(
              chatWnd.windowId,
              'root_event',
              jsonEncode(
                  {'type': 'opened_apps', 'process': jsonData['plist']}));
        }
      });

      sendLogData('init');
    });

    // Audio Player
    audioPlayer.onPlayerComplete.listen((_) {
      DesktopMultiWindow.invokeMethod(chatWnd.windowId, 'root_event',
          jsonEncode({'type': 'audio_slider_complete', 'url': activeURL}));
      DesktopMultiWindow.invokeMethod(
          chatWnd.windowId,
          'root_event',
          jsonEncode({
            'type': 'audio_slider_position_change',
            'url': activeURL,
            'pos': "00:00:00"
          }));
      setState(() {
        activeURL = '';
      });
    });

    audioPlayer.onPositionChanged.listen((Duration pos) {
      DesktopMultiWindow.invokeMethod(
          chatWnd.windowId,
          'root_event',
          jsonEncode({
            'type': 'audio_slider_position_change',
            'url': activeURL,
            'pos': dur2str(pos)
          }));
    });
  }

  @override
  void dispose() async {
    log('dispose');
    super.dispose();

    // Set java_exit_flag to true so java process will be killed automatically
    final Directory dir = await getApplicationDocumentsDirectory();
    String filePath =
        "${dir.path.toString().replaceAll('Documents', 'mplos')}\\java.cnf";
    String content = File(filePath).readAsStringSync();
    final jsonData = jsonDecode(content);
    jsonData['tracking_enable'] = false;
    File(filePath).writeAsStringSync(jsonEncode(jsonData));

    timer.cancel();

    final subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();
    for (final id in subWindowIds) {
      WindowController.fromWindowId(id).hide();
    }
    for (final id in subWindowIds) {
      WindowController.fromWindowId(id).close();
    }
    DesktopMultiWindow.setMethodHandler(null);

    try {
      webSocket.sink.close();
    } catch (_) {}
  }

  Future<dynamic> _handleMethodCallback(
      MethodCall call, int fromWindowId) async {
    handleClearWnd(null);

    final jsonData = jsonDecode(call.arguments.toString());
    if (call.method == 'ws_event') {
      if (jsonData['div'] == 'taskChangeInTimer' ||
          jsonData['div'] == 'takeBreak' ||
          jsonData['div'] == 'resumeWork') {
        sendLogData(jsonData['div']);
      }

      switch (jsonData['div']) {
        case 'startDayWithMission':
        case 'taskChangeInTimer':
          ref.read(timerStateNotifierProvider.notifier).setActiveTask(ref
              .read(timerStateNotifierProvider)
              .tasks
              .where((task) => task.id == int.parse(jsonData['cust_msg']))
              .first);
          break;
        case 'takeBreak':
        case 'resumeWork':
          ref.read(timerStateNotifierProvider.notifier).setTimerStatus(
              jsonData['div'] == 'resumeWork' ? 'active' : 'on_break');
          ref
              .read(timerStateNotifierProvider.notifier)
              .setWorkTime(str2dur(jsonData['cust_msg']));
          break;
        case 'endDay':
          ref.read(timerStateNotifierProvider.notifier).endDay().then((_) {
            ref.read(timerStateNotifierProvider.notifier).sendReport();
            DesktopMultiWindow.invokeMethod(
                0,
                'child_event',
                jsonEncode({
                  'type': 'switch_company',
                  'company_id':
                      ref.read(timerStateNotifierProvider).activeCompany.id
                }));
          });
          break;
      }
    } else if (call.method == 'child_event') {
      log(call.arguments.toString());
      switch (jsonData['type']) {
        case "switch_company":
          ref.read(timerStateNotifierProvider.notifier).selectCompany(ref
              .read(timerStateNotifierProvider)
              .companies
              .where((el) => el.id == jsonData['company_id'])
              .first);
          ref.read(timerStateNotifierProvider.notifier).setActiveTask(null);
          ref.read(timerStateNotifierProvider.notifier).getMissions().then((_) {
            final timerState = ref.read(timerStateNotifierProvider);
            List<Task> tasks = timerState.tasks;
            for (Task task in tasks) {
              ref
                  .read(timerStateNotifierProvider.notifier)
                  .getMissionStatus(task.id);
            }
            goToURL('/select-mission');
          });
          break;
        case 'launchURL':
          launchUrl(Uri.parse(jsonData['url']));
          break;
        case "signout":
          ref.read(timerStateNotifierProvider.notifier).logOut();
          ref.read(timerStateNotifierProvider.notifier).saveCredential('null');
          goToURL('/');
          break;
        case "close":
          final subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();
          for (final id in subWindowIds) {
            WindowController.fromWindowId(id).close();
          }
          appWindow.close();
          break;

        // Audio Slider
        case 'audio_slider_resume':
          audioPlayer.setSourceUrl(jsonData['url']);
          audioPlayer.seek(str2dur(jsonData['elapsed']));
          audioPlayer.resume();
          setState(() {
            activeURL = jsonData['url'];
          });
          DesktopMultiWindow.invokeMethod(
              chatWnd.windowId,
              'root_event',
              jsonEncode({
                'type': 'audio_slider_position_change',
                'url': jsonData['url'],
                'pos': jsonData['elapsed']
              }));
          DesktopMultiWindow.invokeMethod(
              chatWnd.windowId,
              'root_event',
              jsonEncode({
                'type': 'audio_slider_resume',
                'url': jsonData['url'],
              }));
          break;
        case 'audio_slider_pause':
          audioPlayer.pause();
          DesktopMultiWindow.invokeMethod(
              chatWnd.windowId,
              'root_event',
              jsonEncode({
                'type': 'audio_slider_pause',
                'url': jsonData['url'],
              }));
          break;
        case 'audio_slider_duration':
          audioPlayer.setSourceUrl(jsonData['url']).then((_) {
            audioPlayer.getDuration().then((value) {
              DesktopMultiWindow.invokeMethod(
                  chatWnd.windowId,
                  'root_event',
                  jsonEncode({
                    'type': 'audio_slider_duration',
                    'url': jsonData['url'],
                    'duration': dur2str(value!)
                  }));
            });
          });
          break;
      }
    }
  }

  void handleOpenMenu() async {
    if (curVisible == 'option') {
      menuWnd.hide();
      curVisible = 'none';
    } else {
      handleClearWnd(null);

      await WindowManager.instance.setAsFrameless();
      Offset pos = await WindowManager.instance.getPosition();
      curVisible = 'option';
      menuWnd
        ..setFrame(pos.translate(10, -347) & const Size(260, 340))
        ..show();
    }
  }

  void handleOpenChat() async {
    if (curVisible == 'chat') {
      chatWnd.hide();
      curVisible = 'none';
    } else {
      handleClearWnd(null);
      curVisible = 'chat';
      Offset pos = await WindowManager.instance.getPosition();
      chatWnd
        ..setFrame(pos.translate(0, 0) & const Size(1200, 800))
        ..center()
        ..show();
    }
  }

  void handleClearWnd(details) async {
    menuWnd.hide();
    taskWnd.hide();
    timeWnd.hide();

    curVisible = 'none';
  }

  void handleStartDrag(details) async {
    appWindow.startDragging();

    handleClearWnd(details);
  }

  void handleTaskClick() async {
    if (curVisible == 'task') {
      taskWnd.hide();
      curVisible = 'none';
    } else {
      handleClearWnd(null);

      Offset pos = await WindowManager.instance.getPosition();
      await WindowManager.instance.setAsFrameless();
      curVisible = 'task';
      taskWnd
        ..setFrame(pos.translate(65, -507) & const Size(380, 500))
        ..show();
    }
  }

  void handleTimeClick() async {
    if (curVisible == 'time') {
      timeWnd.hide();
      curVisible = 'none';
    } else {
      handleClearWnd(null);

      Offset pos = await WindowManager.instance.getPosition();
      await WindowManager.instance.setAsFrameless();
      curVisible = 'time';
      timeWnd
        ..setFrame(pos.translate(330, -124) & const Size(150, 117))
        ..show();
    }
  }

  void sendScreenshot(String path) async {
    final timerState = ref.read(timerStateNotifierProvider);

    Directory javaDirectory = await getApplicationDocumentsDirectory();
    String logDirPath =
        '${javaDirectory.path.replaceAll('Documents', 'mplos')}\\${timerState.activeCompany.userID}\\${timerState.activeCompany.id}\\${timerState.activeTask == null ? -1 : timerState.activeTask!.id}';
    List<String> chunkPaths = path.split(r'\');
    Directory directory = Directory(logDirPath);

    DateTime today = DateTime.now();
    today = today.subtract(DateTime.now().timeZoneOffset);
    String logFileName = "${today.day}.${today.month}.${today.year}.log";

    if (await directory.exists()) {
      await for (var entity in directory.list()) {
        if (entity is File && entity.path.endsWith(logFileName)) {
          File logFile = File(entity.path);
          String content = logFile.readAsStringSync();
          log(content);
          final jsonData = jsonDecode(content);
          for (var element in (jsonData['softwares'] as List<dynamic>)) {
            if (element['name'].toString() ==
                chunkPaths[chunkPaths.length - 2]) {
              ref
                  .read(timerStateNotifierProvider.notifier)
                  .sendScreenshot(
                      path, element['time'], gmt2utc(DateTime.now().toString()))
                  .then((resMessage) {
                // LocalNotification(
                //   title: "Timer",
                //   body: resMessage,
                // ).show();
                File(path).delete();
              });
            }
          }
        }
      }
    }
  }

  void sendLogData(String option) async {
    // log('send log data $option');

    final timerState = ref.read(timerStateNotifierProvider);
    Directory javaDirectory = await getApplicationDocumentsDirectory();
    String javaDirPath =
        '${javaDirectory.path.replaceAll('Documents', 'mplos')}\\${timerState.activeCompany.userID}\\${timerState.activeCompany.id}';
    Directory directory = Directory(javaDirPath);

    DateTime today = DateTime.now();
    today = today.subtract(DateTime.now().timeZoneOffset);
    String logFileName = "${today.day}.${today.month}.${today.year}.log";

    if (await directory.exists()) {
      await for (var entity
          in directory.list(followLinks: false, recursive: true)) {
        if (entity is File && entity.path.endsWith(logFileName)) {
          File logFile = File(entity.path);
          String content = logFile.readAsStringSync();
          ref
              .read(timerStateNotifierProvider.notifier)
              .sendLog(content)
              .then((_) {
            logFile.delete();
            // LocalNotification(
            //   title: "Timer",
            //   body: "Sent log information successfully",
            // ).show();
          });
        }
      }
    } else {
      log('Directory for log files does not exists: $javaDirPath');
    }
  }

  void handleTakeScreenshot() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    String filePath =
        "${dir.path.toString().replaceAll('Documents', 'mplos')}\\java.cnf";
    String content = File(filePath).readAsStringSync();
    final jsonData = jsonDecode(content);
    jsonData['instant_screenshot'] = true;
    File(filePath).writeAsStringSync(jsonEncode(jsonData));
  }

  void handleToggleScreenRecord() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    String filePath =
        "${dir.path.toString().replaceAll('Documents', 'mplos')}\\java.cnf";
    String content = File(filePath).readAsStringSync();
    final jsonData = jsonDecode(content);
    jsonData['screen_record_flag'] = !isScreenRecord;
    File(filePath).writeAsStringSync(jsonEncode(jsonData));
    setState(() {
      isScreenRecord = !isScreenRecord;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateNotifierProvider);

    return Scaffold(
        body: Container(
      color: AppColors.primary,
      child: Row(children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Row(children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: GestureDetector(
                      onTap: handleOpenMenu,
                      child: const Icon(Icons.more_vert)),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 7.0),
                  child: GestureDetector(
                      onTap: handleOpenChat, child: const Icon(Icons.chat)),
                ),
              ),
            ])),
        Container(height: double.infinity, width: 1.0, color: Colors.white30),
        InkWell(
          onTap: handleTaskClick,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    timerState.activeTask != null
                        ? timerState.activeTask!.name
                        : "Select task",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white, fontSize: 13),
                  ),
                ),
                const Icon(Icons.arrow_drop_up)
              ],
            ),
          ),
        ),
        Container(height: double.infinity, width: 1.0, color: Colors.white30),
        MouseRegion(
            cursor: timerState.activeTask != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            child: GestureDetector(
                onTap:
                    timerState.activeTask != null ? handleTakeScreenshot : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: SvgPicture.asset('assets/images/screenshot-icon.svg',
                      color: Colors.white, width: 40, height: 40),
                ))),
        MouseRegion(
            cursor: timerState.activeTask != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            child: GestureDetector(
                onTap: timerState.activeTask != null
                    ? handleToggleScreenRecord
                    : null,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SvgPicture.asset(
                      'assets/images/screen-recorder-icon.svg',
                      color: isScreenRecord ? Colors.white : Colors.redAccent,
                      width: 40,
                      height: 40),
                ))),
        Container(height: double.infinity, width: 1.0, color: Colors.white30),
        SizedBox(
          width: 165,
          child: InkWell(
            onTap: handleTimeClick,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                      timerState.timerStatus == 'active'
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 25),
                  const SizedBox(width: 4),
                  Text(
                    dur2str(timerState.workTime),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
          ),
        ),
        Container(height: double.infinity, width: 1.0, color: Colors.white30),
        Expanded(
            child: MouseRegion(
          cursor: SystemMouseCursors.move,
          child: GestureDetector(
              onTap: () => handleClearWnd(null),
              onTapDown: handleClearWnd,
              onPanStart: handleStartDrag,
              child: const Icon(Icons.drag_indicator, color: Colors.white54)),
        ))
      ]),
    ));
  }

  String dur2str(Duration duration) {
    return duration
        .toString()
        .split('.')
        .first
        .split(':')
        .map((el) => el.padLeft(2, '0'))
        .join(':');
  }

  Duration str2dur(String time) {
    List<String> arr = time.split(':');
    return Duration(
        hours: int.parse(arr[0]),
        minutes: int.parse(arr[1]),
        seconds: int.parse(arr[2]));
  }

  String gmt2utc(String value) {
    if (value == "null") return value;

    List<String> dateNums = value.split(RegExp(r'[^0-9]'));
    DateTime zeroGMT = DateTime(
        int.parse(dateNums[0]),
        int.parse(dateNums[1]),
        int.parse(dateNums[2]),
        int.parse(dateNums[3]),
        int.parse(dateNums[4]),
        int.parse(dateNums[5]));
    return zeroGMT.subtract(DateTime.now().timeZoneOffset).toString();
  }

  void goToURL(url) async {
    AutoRouter.of(context).replaceNamed(url);
  }
}

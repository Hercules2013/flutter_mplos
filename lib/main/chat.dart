import 'dart:convert';
import 'dart:developer';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mplos_chat/features/chat/presentation/providers/chat_state_provider.dart';
import 'package:mplos_chat/features/log/presentation/providers/log_state_provider.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/chat/message_model.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';

import 'package:mplos_chat/shared/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/shared/widgets/providers/app_state_provider.dart';
import '../routes/app_route.dart';

enum SockMessage {
  shutdown,
  show,
  // MIME_MISSION,
  // MIME_PROCESSES,
  // MIME_MAIN_TIME,
  // MIME_MAIN_TIME_PAUSE,
  // MIME_MAIN_TIME_RESUME,
  // MIME_CURRENT_MISSION,
  // MIME_SOFTWARE_LIST,
}

class ChatApp extends ConsumerStatefulWidget {
  final String feedData;
  const ChatApp(this.feedData, {Key? key}) : super(key: key);

  @override
  ChatAppState createState() => ChatAppState();
}

class ChatAppState extends ConsumerState<ChatApp> {
  final appRouter = AppRouter();

  String get feedData => widget.feedData;

  @override
  void initState() {
    super.initState();

    final jsonData = jsonDecode(feedData);
    String token = jsonData['token'];
    Company activeCompany = Company.fromJson(jsonData['activeCompany']);
    List<Company> companies = (jsonData['companies'] as List<dynamic>)
        .map((el) => Company.fromJson(el))
        .toList();
    Task? activeTask = jsonData['activeTask'] == 'null'
        ? null
        : Task.fromJson(jsonData['activeTask']);
    List<Task> tasks = (jsonData['tasks'] as List<dynamic>)
        .map((el) => Task.fromJson(el))
        .toList();
    Duration workTime = str2dur(jsonData['workTime']);
    int userStatus = jsonData['userStatus'];
    String timerStatus = jsonData['timerStatus'];

    // Base Configuration
    Future.delayed(Duration.zero, () {
      // Set necessary information to chat app
      ref.read(appStateNotifierProvider.notifier).setToken(token);
      ref
          .read(appStateNotifierProvider.notifier)
          .setUserID(activeCompany.userID);
      ref
          .read(appStateNotifierProvider.notifier)
          .setUserName(activeCompany.userName);
      ref
          .read(appStateNotifierProvider.notifier)
          .setCompanyID(activeCompany.id.toString());
      ref
          .read(appStateNotifierProvider.notifier)
          .setCompanyName(activeCompany.name);
      ref
          .read(appStateNotifierProvider.notifier)
          .setProfileUrl(activeCompany.userProfile);
      ref
          .read(appStateNotifierProvider.notifier)
          .setProfileColor(activeCompany.userColor);

      ref.read(appStateNotifierProvider.notifier).setTasks(tasks);

      if (activeTask != null) {
        ref.read(appStateNotifierProvider.notifier).setActiveTask(activeTask);
        ref.read(timerStateNotifierProvider.notifier).setActiveTask(activeTask);
      }

      ref.read(timerStateNotifierProvider.notifier).setToken(token);
      ref.read(timerStateNotifierProvider.notifier).setTasks(tasks);
      ref
          .read(timerStateNotifierProvider.notifier)
          .selectCompany(activeCompany);
      // ref.read(logStateNotifierProvider.notifier).setActivity(
      //     activeCompany.allowedApps
      //         .map((app) =>
      //             Software(title: app, state: SoftwareConcreteState.approved))
      //         .toList(),
      //     DateTime.now());
      ref
          .read(logStateNotifierProvider.notifier)
          .setActivity(activeCompany.allSoftwares, DateTime.now());
      log(activeCompany.allSoftwares.toString());
      ref.read(timerStateNotifierProvider.notifier).setCompanies(companies);
      ref.read(timerStateNotifierProvider.notifier).setWorkTime(workTime);
      ref.read(timerStateNotifierProvider.notifier).setUserStatus(userStatus);
      ref.read(timerStateNotifierProvider.notifier).setTimerStatus(timerStatus);

      // Chat App Processing ....
      final appNotifier = ref.read(appStateNotifierProvider);

      ref.read(chatStateNotifierProvider.notifier).setDefaultParameter({
        'token': appNotifier.token,
        'company_id': appNotifier.companyID,
      });
    });

    // WS Settings
    DesktopMultiWindow.setMethodHandler(_handleMethodCallback);

    //   // WebSocket Configuration
    //   final webSocket = ref.read(webSocketChannelProvider);

    //   webSocket.stream.handleError((error) {
    //     if (error is WebSocketChannelException) {
    //       // WebSocketChannelException contains the reason for the error
    //       log('Error: ${error.message}');
    //     } else {
    //       // Handle other types of errors here
    //       log('Unknown error occurred');
    //     }
    //   });

    //   webSocket.stream.listen((event) {
    //     final message = event.toString();

    //     log(message);

    //     if (message.compareTo(SockMessage.shutdown.name) == 0) {
    //       exit(0);
    //     } else if (message.compareTo(SockMessage.show.name) == 0) {
    //       WindowManager.instance.show();
    //     } else if (message.startsWith(SockMessage.MIME_MISSION.name)) {
    //       List<Map<String, dynamic>> missions =
    //           jsonDecode(message.substring("MIME_MISSION:".length))
    //               .cast<Map<String, dynamic>>();

    //       List<Task> tasks = missions
    //           .map((mission) => Task(
    //               id: int.parse(mission['id']),
    //               name: mission['name'],
    //               status: mission['status'],
    //               link: mission['link']))
    //           .toList();

    //       ref.read(appStateNotifierProvider.notifier).setTasks(tasks);
    //       // MIME_MISSION:[{"status_id":"413","name":"User profile photo fixing","mission_status":{"id":"413","project_id":"8","status":"Backlog","color":"#828282","is_default":"1","position":"2","created_at":"2022-09-07 05:47:30","updated_at":"2022-09-08 12:01:39"},"id":"129376","title":null,"project_id":"8","link":"http://mplos.mplos.com/project/15ea40c1acd2cdc2646900c7e013dcba","description":"&lt;p&gt;This is being used for user image fixing&lt;/p&gt;","current_done":null,"due_date":"01/01/1970","estimation":null,"progress":"0","status":"Backlog","company_id":"1","company_name":"mplos","statusBucket":{"status":true,"message":null,"data":[{"id":"375","status":"Completed","color":"#6d44b5"},{"id":"413","status":"Backlog","color":"#828282"},{"id":"657","status":"QA-1","color":"#b61919"},{"id":"658","status":"QA-2","color":"#71856e"},{"id":"659","status":"QA-3","color":"#d8e8eb"},{"id":"660","status":"QA-4","color":"#3a92a0"},{"id":"661","status":"QA-5","color":"#21042e"},{"id":"662","status":"QA-6","color":"#760e0e"},{"id":"663","status":"sdsd","color":"#963131"}]}},{"status_id":"413","name":"Upload image does not display","mission_status":{"id":"413","project_id":"8","status":"Backlog","color":"#828282","is_default":"1","position":"2","created_at":"2022-09-07 05:47:30","updated_at":"2022-09-08 12:01:39"},"id":"129377","title":null,"project_id":"8","link":"http://mplos.mplos.com/project/15ea40c1acd2cdc2646900c7e013dcba","description":"&lt;p&gt;Need to fix it because upload image does not show&lt;/p&gt;","current_done":null,"due_date":"01/01/1970","estimation":null,"progress":"0","status":"Backlog","company_id":"1","company_name":"mplos","statusBucket":{"status":true,"message":null,"data":[{"id":"375","status":"Completed","color":"#6d44b5"},{"id":"413","status":"Backlog","color":"#828282"},{"id":"657","status":"QA-1","color":"#b61919"},{"id":"658","status":"QA-2","color":"#71856e"},{"id":"659","status":"QA-3","color":"#d8e8eb"},{"id":"660","status":"QA-4","color":"#3a92a0"},{"id":"661","status":"QA-5","color":"#21042e"},{"id":"662","status":"QA-6","color":"#760e0e"},{"id":"663","status":"sdsd","color":"#963131"}]}},{"status_id":"413","name":"User profile background fixing","mission_status":{"id":"413","project_id":"8","status":"Backlog","color":"#828282","is_default":"1","position":"2","created_at":"2022-09-07 05:47:30","updated_at":"2022-09-08 12:01:39"},"id":"129378","title":null,"project_id":"8","link":"http://mplos.mplos.com/project/15ea40c1acd2cdc2646900c7e013dcba","description":"&lt;p&gt;Need to fix of user background color&lt;/p&gt;","current_done":null,"due_date":"01/01/1970","estimation":null,"progress":"0","status":"Backlog","company_id":"1","company_name":"mplos","statusBucket":{"status":true,"message":null,"data":[{"id":"375","status":"Completed","color":"#6d44b5"},{"id":"413","status":"Backlog","color":"#828282"},{"id":"657","status":"QA-1","color":"#b61919"},{"id":"658","status":"QA-2","color":"#71856e"},{"id":"659","status":"QA-3","color":"#d8e8eb"},{"id":"660","status":"QA-4","color":"#3a92a0"},{"id":"661","status":"QA-5","color":"#21042e"},{"id":"662","status":"QA-6","color":"#760e0e"},{"id":"663","status":"sdsd","color":"#963131"}]}}]
    //     } else if (message.startsWith(SockMessage.MIME_CURRENT_MISSION.name)) {
    //       String activeMission =
    //           message.substring("MIME_CURRENT_MISSION:".length);
    //       if (activeMission == 'null') return;

    //       Map<String, dynamic> mission = jsonDecode(activeMission);
    //       log(Task(
    //               id: int.parse(mission['id']),
    //               name: mission['name'],
    //               status: mission['status'],
    //               link: mission['link'])
    //           .toString());
    //       ref.read(appStateNotifierProvider.notifier).setActiveTask(Task(
    //           id: int.parse(mission['id']),
    //           name: mission['name'],
    //           status: mission['status'],
    //           link: mission['link']));
    //       // MIME_CURRENT_MISSION:{"status_id":"413","name":"User profile photo fixing","mission_status":{"id":"413","project_id":"8","status":"Backlog","color":"#828282","is_default":"1","position":"2","created_at":"2022-09-07 05:47:30","updated_at":"2022-09-08 12:01:39"},"id":"129376","title":null,"project_id":"8","link":"http://mplos.mplos.com/project/15ea40c1acd2cdc2646900c7e013dcba","description":"&lt;p&gt;This is being used for user image fixing&lt;/p&gt;","current_done":null,"due_date":"01/01/1970","estimation":null,"progress":"0","status":"Backlog","company_id":"1","company_name":"mplos","statusBucket":{"status":true,"message":null,"data":[{"id":"375","status":"Completed","color":"#6d44b5"},{"id":"413","status":"Backlog","color":"#828282"},{"id":"657","status":"QA-1","color":"#b61919"},{"id":"658","status":"QA-2","color":"#71856e"},{"id":"659","status":"QA-3","color":"#d8e8eb"},{"id":"660","status":"QA-4","color":"#3a92a0"},{"id":"661","status":"QA-5","color":"#21042e"},{"id":"662","status":"QA-6","color":"#760e0e"},{"id":"663","status":"sdsd","color":"#963131"}]}}
    //     } else if (message.startsWith(SockMessage.MIME_MAIN_TIME_PAUSE.name)) {
    //       ref.read(appStateNotifierProvider.notifier).pauseTimer();
    //     } else if (message.startsWith(SockMessage.MIME_MAIN_TIME_RESUME.name)) {
    //       ref.read(appStateNotifierProvider.notifier).playTimer();
    //     } else if (message.startsWith(SockMessage.MIME_MAIN_TIME.name)) {
    //       List<String> workTime =
    //           message.substring("MIME_MAIN_TIME:".length).split(':');
    //       Duration workDuration = Duration(
    //           hours: int.parse(workTime[0]),
    //           minutes: int.parse(workTime[1]),
    //           seconds: int.parse(workTime[2]));

    //       ref.read(appStateNotifierProvider.notifier).setWorkTime(workDuration);
    //       ref.read(appStateNotifierProvider.notifier).playTimer();
    //     } else if (message.startsWith(SockMessage.MIME_PROCESSES.name)) {
    //       List<dynamic> processes =
    //           jsonDecode(message.substring("MIME_PROCESSES:".length))
    //               .cast<Map<String, dynamic>>();

    //       // List<Task> tasks = processes
    //       //     .map((mission) => Task(
    //       //         id: int.parse(mission['id']),
    //       //         title: mission['name'],
    //       //         status: mission['status'],
    //       //         link: mission['link']))
    //       //     .toList();

    //       ref.read(logStateNotifierProvider.notifier).setActivity(
    //           processes
    //               .map((p) => Software(
    //                   path: p['processPath'],
    //                   icon: p['iconPath'].toString(),
    //                   title: p['title'],
    //                   startTime: int.parse(p['start'].toString()),
    //                   usage: Duration(seconds: int.parse(p['usage'].toString()))))
    //               .toList(),
    //           DateTime.now());
    //     } else if (message.startsWith(SockMessage.MIME_SOFTWARE_LIST.name)) {
    //       List<String> softwares =
    //           message.substring("MIME_SOFTWARE_LIST:".length).split(',');
    //     } else {
    //       final jsonData = jsonDecode(message);

    //       switch (jsonData['div']) {
    //         case 'new_message':
    //           final msg = jsonDecode(jsonData['cust_msg'].toString());

    //           ref.read(chatStateNotifierProvider.notifier).receiveMessage(
    //               Message(
    //                   id: msg['id'],
    //                   // type: msg['msg_type'],
    //                   message: msg['message'],
    //                   sendTime: msg['time'],
    //                   isGroupMessage: msg['is_group_msg'] == 'yes',
    //                   sender: msg['sender'],
    //                   receiver: msg['receiver'].toString()),
    //               msg['sender'].toString(),
    //               msg['receiver'].toString());
    //           break;
    //         case 'BlueTick':
    //           String id = jsonData['sender_id'].toString().split('_').last;
    //           ref.read(chatStateNotifierProvider.notifier).readByPeer(id);
    //           break;
    //         case 'refreshUserStatus':
    //           String status = jsonData['cust_msg'].toString();
    //           String id = jsonData['sender_id'].toString().split('_').last;
    //           ref
    //               .read(chatStateNotifierProvider.notifier)
    //               .refreshUserStatus(id, status);
    //           break;
    //         case 'Delete_Chat_Conversation':
    //           String chatID = jsonData['cust_msg'].toString();
    //           ref.read(chatStateNotifierProvider.notifier).deleteChat(chatID);
    //           break;
    //         case 'softwareRequestAccepted':
    //           log("${jsonData['test']} softare has approved");
    //           break;
    //         case 'softwareRequestRejected':
    //           log("${jsonData['test']} softare has rejected");
    //           break;
    //         case 'Update_MSG':
    //           String msgID = jsonData['cust_msg'].toString();
    //           ref.read(chatStateNotifierProvider.notifier).addEditSign(msgID);
    //           break;
    //       }
    //     }
    //   });
  }

  @override
  dispose() {
    DesktopMultiWindow.setMethodHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleMethodCallback(
      MethodCall call, int fromWindowId) async {
    final jsonData = jsonDecode(call.arguments.toString());

    if (call.method == 'root_event') {
      switch (jsonData['type']) {
        case 'timer':
          ref
              .read(timerStateNotifierProvider.notifier)
              .setWorkTime(str2dur(jsonData['duration']));
          break;
        case 'audio_slider_resume':
          ref.read(chatStateNotifierProvider.notifier).updateAudioSlider(
              jsonData['url'], Duration.zero, 'status', true);
        case 'audio_slider_position_change':
          ref.read(chatStateNotifierProvider.notifier).updateAudioSlider(
              jsonData['url'], str2dur(jsonData['pos']), 'elapsed', false);
          break;
        case 'audio_slider_duration':
          ref.read(chatStateNotifierProvider.notifier).updateAudioSlider(
              jsonData['url'], str2dur(jsonData['duration']), 'total', false);
          break;
        case 'audio_slider_pause':
        case 'audio_slider_complete':
          ref.read(chatStateNotifierProvider.notifier).updateAudioSlider(
              jsonData['url'], Duration.zero, 'status', false);
          break;
        case 'opened_apps':
          ref.read(logStateNotifierProvider.notifier).setActivity(
              (jsonData['process'] as List<dynamic>)
                  .map((p) => Software(
                      // path: p['processPath'],
                      icon: p['ico'].toString(),
                      title: p['name'],
                      startTime: p['start_time'],
                      usage:
                          Duration(seconds: int.parse(p['time'].toString()))))
                  .toList(),
              DateTime.now());
          break;
      }
    } else {
      switch (jsonData['div']) {
        case 'new_message':
          final msg = jsonDecode(jsonData['cust_msg'].toString());
          ref.read(chatStateNotifierProvider.notifier).receiveMessage(
              Message(
                  id: msg['id'],
                  // type: msg['msg_type'],
                  message: msg['message'],
                  sendTime: msg['time'],
                  isGroupMessage: msg['is_group_msg'] == 'yes',
                  sender: msg['sender'],
                  receiver: msg['receiver'].toString()),
              msg['sender'].toString(),
              msg['receiver'].toString());
          break;
        case 'BlueTick':
          String id = jsonData['sender_id'].toString().split('_').last;
          ref.read(chatStateNotifierProvider.notifier).readByPeer(id);
          break;
        case 'refreshUserStatus':
          String status = jsonData['cust_msg'].toString();
          String id = jsonData['sender_id'].toString(); //.split('_').last;
          ref
              .read(chatStateNotifierProvider.notifier)
              .refreshUserStatus(id, status);
          if (id == ref.read(timerStateNotifierProvider).activeCompany.userID) {
            ref.read(appStateNotifierProvider.notifier).setUserStatus(status);
          }
          break;
        case 'Delete_Chat_Conversation':
        case 'Delete_Chat_Group':
          String chatID = jsonData['cust_msg'].toString();
          ref.read(chatStateNotifierProvider.notifier).deleteChat(chatID);
          break;
        case 'DeleteMessage':
          String msgID = jsonData['cust_msg'].toString();
          msgID = msgID.startsWith('MSG') ? msgID.split('_').last : msgID;
          ref.read(chatStateNotifierProvider.notifier).deleteMessage(msgID);
          break;
        case 'softwareRequestAccepted':
          final jsonSoft = jsonDecode(jsonData['cust_msg'].toString());
          ref
              .read(logStateNotifierProvider.notifier)
              .updateActivity(jsonSoft['software_name'], 'accept');
          break;
        case 'softwareBlocked':
        case 'softwareRequestRejected':
          final jsonSoft = jsonDecode(jsonData['cust_msg'].toString());
          ref
              .read(logStateNotifierProvider.notifier)
              .updateActivity(jsonSoft['software_name'], 'reject');
          break;
        case 'Update_MSG':
          String msgID = jsonData['cust_msg'].toString();
          ref.read(chatStateNotifierProvider.notifier).addEditSign(msgID);
          break;
        case 'takeBreak':
        case 'resumeWork':
          ref.read(timerStateNotifierProvider.notifier).setTimerStatus(
              jsonData['div'] == 'resumeWork' ? 'active' : 'not_active');
          ref
              .read(timerStateNotifierProvider.notifier)
              .setWorkTime(str2dur(jsonData['cust_msg']));
          break;
        case 'taskChangeInTimer':
          ref.read(appStateNotifierProvider.notifier).setActiveTask(ref
              .read(appStateNotifierProvider)
              .tasks
              .where((el) => el.id == int.parse(jsonData['cust_msg']))
              .first);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mplos App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routeInformationParser: appRouter.defaultRouteParser(),
      routerDelegate: appRouter.delegate(),
      debugShowCheckedModeBanner: false,
    );
  }

  Duration str2dur(String time) {
    List<String> arr = time.split(':');
    return Duration(
        hours: int.parse(arr[0]),
        minutes: int.parse(arr[1]),
        seconds: int.parse(arr[2]));
  }

  DateTime str2date(String dateString) {
    List<String> dateTimeParts = dateString.split(' ');
    List<String> dateComponents = dateTimeParts[0].split('-');
    List<String> timeComponents = dateTimeParts[1].split(':');

    return DateTime(
      int.parse(dateComponents[0]), // Year
      int.parse(dateComponents[1]), // Month
      int.parse(dateComponents[2]), // Day
      int.parse(timeComponents[0]), // Hour
      int.parse(timeComponents[1]), // Minute
      int.parse(timeComponents[2]), // Second
    );
  }
}

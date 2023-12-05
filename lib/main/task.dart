import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/features/timer/presentation/widgets/active_task_item.dart';
import 'package:mplos_chat/features/timer/presentation/widgets/task_item.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/theme/app_theme.dart';

class TaskApp extends ConsumerStatefulWidget {
  final String feedData;
  const TaskApp(this.feedData, {Key? key}) : super(key: key);

  @override
  TaskAppState createState() => TaskAppState();
}

class TaskAppState extends ConsumerState<TaskApp> {
  ScrollController scrollController = ScrollController();

  String get feedData => widget.feedData;

  int openedTaskID = -1;

  @override
  void initState() {
    super.initState();

    final jsonData = jsonDecode(feedData);

    String token = jsonData['token'];
    Company activeCompany = Company.fromJson(jsonData['activeCompany']);
    Task? activeTask = jsonData['activeTask'] != 'null'
        ? Task.fromJson(jsonData['activeTask'])
        : null;
    List<Task> tasks = (jsonData['tasks'] as List<dynamic>)
        .map((el) => Task.fromJson(el))
        .toList();
    String progress = jsonData['progress'],
        progressColor = jsonData['progressColor'];

    Future.delayed(Duration.zero, () {
      ref.read(timerStateNotifierProvider.notifier).setToken(token);
      ref
          .read(timerStateNotifierProvider.notifier)
          .selectCompany(activeCompany);
      ref.read(timerStateNotifierProvider.notifier).setTasks(tasks);
      ref.read(timerStateNotifierProvider.notifier).setActiveTask(activeTask);
      ref
          .read(timerStateNotifierProvider.notifier)
          .setActiveProgress(progress, progressColor);
    });

    DesktopMultiWindow.setMethodHandler(_handleMethodCallback);
  }

  @override
  dispose() {
    DesktopMultiWindow.setMethodHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleMethodCallback(
      MethodCall call, int fromWindowId) async {
    final data = call.arguments.toString();
    final jsonData = jsonDecode(data);
    if (call.method == 'root_event') {
      if (jsonData['type'] == 'timer') {
        ref.read(timerStateNotifierProvider.notifier).increaseTaskTime();
      }
    } else {
      switch (jsonData['div']) {
        case 'startDayWithMission':
        case 'taskChangeInTimer':
          ref.read(timerStateNotifierProvider.notifier).setActiveTask(ref
              .read(timerStateNotifierProvider)
              .tasks
              .where((task) => task.id == int.parse(jsonData['cust_msg']))
              .first);
      }
    }
  }

  void handleCallback(type, taskID) {
    switch (type) {
      case 'openTask':
        setState(() {
          openedTaskID = taskID;
        });
        break;
      case 'startTask':
        // https://mplos.com/api.php?api=daily_work&action=start&company_id=1&token=N7HPYP977D4SERTASDFG&select_mission=129378
        ref.read(timerStateNotifierProvider.notifier).startDailyWork(taskID);
        // log(ref.read(appStateNotifierProvider).token);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateNotifierProvider);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            timerState.activeTask != null
                ? ActiveTaskItem(timerState.activeTask!, timerState.progress,
                    timerState.progressColor)
                : const SizedBox.shrink(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
              child: Text("Next:",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: const Color(0xFF596064))),
            ),
            Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    // thumbVisibility: MaterialStateProperty.all(true),
                    thumbColor: MaterialStateProperty.all(
                        AppColors.primary), // Replace with your desired color
                  ),
                ),
                child: Expanded(
                  child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                          children: timerState.tasks
                              .where((task) =>
                                  timerState.activeTask == null ||
                                  task.id != timerState.activeTask!.id)
                              .map((task) => TaskItem(task,
                                  openedTaskID == task.id, handleCallback))
                              .toList())),
                )),
          ]),
        ));
  }

  Duration str2dur(String time) {
    List<String> arr = time.split(':');
    return Duration(
        hours: int.parse(arr[0]),
        minutes: int.parse(arr[1]),
        seconds: int.parse(arr[2]));
  }
}

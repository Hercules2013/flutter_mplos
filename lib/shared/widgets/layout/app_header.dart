import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';

import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/widgets/providers/app_state_provider.dart';

class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  TextEditingController taskController = TextEditingController();
  List<DropdownMenuEntry> missions = [];
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateNotifierProvider);
    final timerState = ref.watch(timerStateNotifierProvider);
    // final webSocket = ref.read(webSocketChannelProvider);

    missions.clear();
    for (var task in appState.tasks) {
      missions.add(DropdownMenuEntry(
          value: task.id,
          label: task.name,
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(AppColors.black),
              // padding: MaterialStateProperty.all(const EdgeInsets.all(20.0)),
              fixedSize: MaterialStateProperty.all(const Size(300, 50)),
              textStyle: MaterialStateProperty.all(
                  GoogleFonts.dmSans(fontSize: 14, color: AppColors.black)))));
    }
    taskController.text = appState.activeTask.name;

    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: const [
        // IconButton(
        //   icon: const Icon(Icons.close),
        //   onPressed: () async {
        //     // appWindow.close();
        //     // webSocket.sink.add("show");
        //     // appWindow.hide();
        //   },
        // ),
      ],
      title: Row(children: [
        SizedBox(width: 410, child: Text(appState.companyName)),
        Consumer(builder: (context, ref, child) {
          return GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownMenu(
                  controller: taskController,
                  dropdownMenuEntries: missions,
                  onSelected: handleTaskChange,
                  width: 210,
                  trailingIcon: const Icon(Icons.expand_more,
                      color: AppColors.white, size: 20),
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.white),
                  inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      constraints: BoxConstraints(minHeight: 36)),
                  requestFocusOnTap: false,
                  menuStyle: MenuStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.white)),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child:
                        Container(width: 2, height: 30, color: Colors.white24)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: toggleTimer,
                        icon: Icon(
                            timerState.timerStatus == 'active'
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 25)),
                    const SizedBox(width: 4),
                    InkWell(
                        onTap: () {
                          showTimerWidget(const Offset(825, 50), context);
                        },
                        child: Text(dur2str(timerState.workTime)))
                  ],
                )
              ],
            ),
          );
        })
      ]),
    );
  }

  handleTaskChange(taskID) {
    final appState = ref.read(appStateNotifierProvider);

    Task activeTask = appState.tasks.firstWhere((task) => task.id == taskID);

    ref.read(appStateNotifierProvider.notifier).setActiveTask(activeTask);
    ref.read(timerStateNotifierProvider.notifier).startDailyWork(taskID);
  }

  toggleTimer() {
    final appState = ref.read(appStateNotifierProvider);

    if (appState.activeTask.isWorking) {
      ref.read(appStateNotifierProvider.notifier).pauseTimer();
      // ref.read(webSocketChannelProvider).sink.add('pause');
    } else {
      ref.read(appStateNotifierProvider.notifier).playTimer();
      // ref.read(webSocketChannelProvider).sink.add('resume');
    }

    ref
        .read(timerStateNotifierProvider.notifier)
        .pauseResumeWork(appState.activeTask.isWorking ? 'breake' : 'resume');
  }

  void showTimerWidget(Offset position, BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect positionBounds = RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    );

    showMenu(
            context: context,
            elevation: 8,
            // initialValue: MenuOption.option1,
            position: positionBounds,
            items: [
              const PopupMenuItem(
                  value: 'end',
                  child: Row(children: [
                    Icon(Icons.power_settings_new, color: Colors.red),
                    SizedBox(width: 8),
                    Text("End the day")
                  ])),
              const PopupMenuItem(
                  value: 'break',
                  child: Row(children: [
                    Icon(Icons.coffee, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text("Take a break")
                  ]))
            ],
            color: AppColors.white)
        .then((String? selectedValue) {
      switch (selectedValue) {
        case 'end':
          // ref.read(webSocketChannelProvider).sink.add('MIME_MISSION_TIMER_END');
          DesktopMultiWindow.invokeMethod(
              0, 'child_event', jsonEncode({'type': 'endDay'}));
          break;
        case 'break':
          // ref
          //     .read(webSocketChannelProvider)
          //     .sink
          //     .add('MIME_MISSION_TIMER_BREAK');
          break;
        default:
          break;
      }
    });
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
}

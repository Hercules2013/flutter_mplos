import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';

import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

@RoutePage()
class MissionScreen extends ConsumerStatefulWidget {
  static const String routeName = 'MissionScreen';

  const MissionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> {
  String curOption = 'withoutTask', curMission = '';

  @override
  void initState() {
    super.initState();

    WindowManager.instance.setSize(const Size(380, 500));
    WindowManager.instance.setAlignment(Alignment.bottomRight);

    Future.delayed(Duration.zero, () {
      final timerState = ref.read(timerStateNotifierProvider);
      log(timerState.companies.toString());
      log(timerState.activeCompany.toString());
      log(timerState.tasks.toString());
      log(timerState.activeTask.toString());
    });

    // ref.read(timerStateNotifierProvider.notifier).getMissions();
    // https://mplos.com/api.php?api=daily_work&action=get_missions&token=N7HPYP977D4SERTASDFG&company_id=1
  }

  void handleStartDrag(details) {
    appWindow.startDragging();
  }

  void handleClose() {
    appWindow.close();
  }

  void handleOptionChange(value) {
    setState(() {
      curOption = value.toString();
    });
  }

  void handleSelectMission(Task? task) {
    ref.read(timerStateNotifierProvider.notifier).setActiveTask(task);
  }

  void handleStartWork() async {
    // https://mplos.com/api.php?api=daily_work&action=start&company_id=1&token=N7HPYP977D4SERTASDFG&select_mission=134848
    final timerState = ref.read(timerStateNotifierProvider);
    Task? activeTask = timerState.activeTask;
    ref
        .read(timerStateNotifierProvider.notifier)
        .startDailyWork(activeTask == null ? -1 : activeTask.id)
        .then((_) async {
      await WindowManager.instance.setSize(const Size(436, 50));
      await WindowManager.instance.setAlignment(Alignment.bottomRight);

      // Save necessary information to java.cnf
      log('Creating java.cnf file ...');
      final dataForJava = jsonEncode({
        "company_id": timerState.activeCompany.id,
        "mission_id":
            timerState.activeTask == null ? -1 : timerState.activeTask!.id,
        "user_id": int.parse(timerState.activeCompany.userID),
        "approved_apps": timerState.activeCompany.allowedApps,
        "screenshot_interval": 5,
        "instant_screenshot": false,
        "screen_record_flag": false,
        "tracking_enable": true
      });

      final Directory dir = await getApplicationDocumentsDirectory();
      String filePath =
          "${dir.path.toString().replaceAll('Documents', 'mplos')}\\java.cnf";
      Directory mplosDir =
          Directory(dir.path.toString().replaceAll('Documents', 'mplos'));
      if (!mplosDir.existsSync()) {
        mplosDir.createSync(recursive: true);
      }
      File(filePath).writeAsString(dataForJava);

      goToURL('/timer');
    });
  }

  void handleSkip() {}

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateNotifierProvider);

    return Scaffold(
        body: Column(children: [
      GestureDetector(
        onPanStart: handleStartDrag,
        child: Container(
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const IconButton(onPressed: null, icon: Icon(Icons.window)),
                  Text("Welcome - Start Your Day",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.white)),
                  IconButton(
                      onPressed: handleClose, icon: const Icon(Icons.close))
                ]),
          ),
        ),
      ),
      Column(children: [
        const SizedBox(height: 12.0),
        Image.asset('assets/images/SplashRocket.png', width: 160, height: 133),
        const SizedBox(height: 12.0),
        Center(
            child: Text("How would you like to start your day?",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 17))),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(children: [
              RadioListTile(
                  value: 'withoutTask',
                  title: Text('Start the day with no particular task',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: curOption == 'withoutTask'
                              ? AppColors.primary
                              : AppColors.lightGrey,
                          fontSize: 15)),
                  groupValue: curOption,
                  fillColor: MaterialStateProperty.all(
                      curOption == 'withoutTask'
                          ? AppColors.primary
                          : AppColors.lightGrey),
                  onChanged: handleOptionChange),
              RadioListTile(
                  value: 'withTask',
                  title: Text('Select a task to start the day with',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: curOption == 'withTask'
                              ? AppColors.primary
                              : AppColors.lightGrey,
                          fontSize: 15)),
                  groupValue: curOption,
                  fillColor: MaterialStateProperty.all(curOption == 'withTask'
                      ? AppColors.primary
                      : AppColors.lightGrey),
                  onChanged:
                      timerState.tasks.isNotEmpty ? handleOptionChange : null),
              curOption == 'withoutTask'
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: 260,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          scrollbarTheme: ScrollbarThemeData(
                            // thumbVisibility: MaterialStateProperty.all(true),
                            thumbColor: MaterialStateProperty.all(AppColors
                                .primary), // Replace with your desired color
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.lightGrey)),
                          child: DropdownButton<Task>(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppColors.black),
                              dropdownColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              menuMaxHeight: 200,
                              isExpanded: true,
                              value: timerState.activeTask,
                              icon: const Icon(Icons.expand_more,
                                  color: AppColors.primary),
                              underline: const SizedBox.shrink(),
                              items: timerState.tasks.map((Task task) {
                                return DropdownMenuItem<Task>(
                                  value: task,
                                  // child: MiniTaskItem(value),
                                  child: Text(task.name),
                                );
                              }).toList(),
                              onChanged: handleSelectMission),
                        ),
                      ))
            ])),
      ]),
      const SizedBox(height: 18.0),
      Container(
          width: double.infinity, height: 1.0, color: AppColors.lightGrey),
      const SizedBox(height: 18.0),
      ElevatedButton(
          onPressed: !timerState.isLoading ? handleStartWork : null,
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(timerState.isLoading
                  ? AppColors.lightGrey
                  : AppColors.primary)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.work, color: AppColors.white, size: 18),
              const SizedBox(width: 8.0),
              Text("Start Your Day",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 14, color: AppColors.white))
            ]),
          )),
      // const SizedBox(height: 12.0),
      // InkWell(
      //   onTap: handleSkip,
      //   child: const Text("Skip",
      //       style: TextStyle(decoration: TextDecoration.underline)),
      // ),
      // const SizedBox(height: 18.0),
    ]));
  }

  void goToURL(url) async {
    AutoRouter.of(context).replaceNamed(url);
  }
}

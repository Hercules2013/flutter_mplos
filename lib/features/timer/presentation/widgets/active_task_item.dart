// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveTaskItem extends ConsumerStatefulWidget {
  Task task;
  String progress, progressColor;
  ActiveTaskItem(this.task, this.progress, this.progressColor, {super.key});

  @override
  ConsumerState<ActiveTaskItem> createState() => _ActiveTaskItemState();
}

class _ActiveTaskItemState extends ConsumerState<ActiveTaskItem> {
  Task get task => widget.task;
  String get progress => widget.progress;
  String get progressColor => widget.progressColor;

  void handleChangeTaskStatus() {}

  copyLinkToClipboard() {
    FlutterClipboard.copy(task.link);
  }

  openLinkInBrowser() {
    launchUrl(Uri.parse(task.link));
  }

  @override
  Widget build(BuildContext context) {
    TaskStatus curStatus =
        task.allStatus.where((el) => el.status == task.status).first;
    final textStyle = GoogleFonts.dmSans(
        color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500);
    return SizedBox(
      height: 175,
      child: Container(
        color: const Color.fromARGB(32, 0, 159, 195),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Now working on:"),
              Row(children: [
                IconButton(
                    onPressed: copyLinkToClipboard,
                    splashRadius: 4.0,
                    icon: const Icon(
                      Icons.link,
                      color: AppColors.lightGrey,
                      size: 20,
                    )),
                IconButton(
                    onPressed: openLinkInBrowser,
                    splashRadius: 4.0,
                    icon: const Icon(
                      Icons.open_in_new,
                      color: AppColors.lightGrey,
                      size: 20,
                    ))
              ])
            ]),
            const SizedBox(height: 8),
            Text(task.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
              child: Row(children: [
                SizedBox(
                  width: 75,
                  child: Text(
                      task.workDuration
                          .toString()
                          .split('.')
                          .first
                          .padLeft(8, '0'),
                      style:
                          TextStyle(color: getColorFromString(progressColor))),
                ),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                      value: task.estimation.isEmpty
                          ? int.parse(
                                  progress.substring(0, progress.length - 1)) /
                              100
                          : task.workDuration.inSeconds /
                              str2dur(task.estimation).inSeconds,
                      minHeight: 10.0,
                      color: getColorFromString(progressColor),
                      backgroundColor: AppColors.lightGrey),
                ),
                const SizedBox(width: 12.0),
                Text(task.estimation.isEmpty ? 'N/A' : task.estimation)
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Task Status: "),
                PopupMenuButton<TaskStatus>(
                    onSelected: (TaskStatus status) {
                      ref
                          .read(timerStateNotifierProvider.notifier)
                          .changeMissionStatus(status.id);
                    },
                    tooltip: '',
                    offset: const Offset(0, 50),
                    color: Colors.white,
                    itemBuilder: (_) {
                      return task.allStatus
                          .map((status) => PopupMenuItem<TaskStatus>(
                              value: status,
                              child: Row(children: [
                                Container(
                                    width: 5,
                                    height: 30,
                                    color: getColorFromString(status.color)),
                                const SizedBox(width: 8),
                                Text(status.status, style: textStyle)
                              ])))
                          .toList();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 12.0),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 4.0),
                          decoration: BoxDecoration(
                              color: getColorFromString(curStatus.color),
                              borderRadius: BorderRadius.circular(8.0)),
                          child: SizedBox(
                            width: 160,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, right: 6.0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox.shrink(),
                                    Text(task.status,
                                        style: textStyle.copyWith(
                                            color: Colors.white)),
                                    const Icon(Icons.arrow_drop_down)
                                  ]),
                            ),
                          )),
                    )),
                // DropdownButton(
                //   style: Theme.of(context)
                //       .textTheme
                //       .bodyMedium!
                //       .copyWith(color: AppColors.black),
                //   dropdownColor: Colors.white,
                //   padding: EdgeInsets.zero,
                //   value: task.status,
                //   items: task.allStatus
                //       .map((status) => DropdownMenuItem(
                //           value: status.status,
                //           child: Row(children: [
                //             Container(
                //                 width: 5,
                //                 height: 30,
                //                 color: getColorFromString(status.color)),
                //             const SizedBox(width: 8),
                //             Text(status.status)
                //           ])))
                //       .toList(),
                //   onChanged: (value) {},
                // )
              ],
            )
          ]),
        ),
      ),
    );
  }

  Duration str2dur(String time) {
    List<String> arr = time.split(':');
    return Duration(
        hours: int.parse(arr[0]),
        minutes: int.parse(arr[1]),
        seconds: int.parse(arr[2]));
  }

  Color getColorFromString(String colorString) {
    if (colorString.startsWith('rgba')) {
      List<String> rgbaValues =
          colorString.replaceAll('rgba(', '').replaceAll(')', '').split(',');

      int red = int.parse(rgbaValues[0].trim());
      int green = int.parse(rgbaValues[1].trim());
      int blue = int.parse(rgbaValues[2].trim());
      double alpha = double.parse(rgbaValues[3].trim());

      return Color.fromARGB((alpha * 255).toInt(), red, green, blue);
    } else if (colorString.startsWith('rgb')) {
      List<String> rgbValues =
          colorString.replaceAll('rgb(', '').replaceAll(')', '').split(',');

      int red = int.parse(rgbValues[0].trim());
      int green = int.parse(rgbValues[1].trim());
      int blue = int.parse(rgbValues[2].trim());

      return Color.fromRGBO(red, green, blue, 1);
    } else if (colorString.startsWith("#")) {
      return Color(
          0xff000000 + int.parse(colorString.replaceAll('#', ''), radix: 16));
      // } else
    }

    return AppColors.primary;
  }
}

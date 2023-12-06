import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class TaskItem extends ConsumerStatefulWidget {
  Task task;
  bool isOpened;
  Function callback;
  TaskItem(this.task, this.isOpened, this.callback, {super.key});

  @override
  ConsumerState<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends ConsumerState<TaskItem> {
  Task get task => widget.task;
  Function get callback => widget.callback;
  bool get isOpened => widget.isOpened;

  void handleToggleOpen() {
    setState(() {
      callback('openTask', !isOpened ? task.id : -1);
    });
  }

  void handleStartTask() {
    callback('startTask', task.id);
  }

  copyLinkToClipboard() {
    FlutterClipboard.copy(task.link);
  }

  openLinkInBrowser() {
    launchUrl(Uri.parse(task.link));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
          onTap: handleToggleOpen,
          child: !isOpened
              ? Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: Text(task.name)),
                  ],
                )
              : SizedBox(
                  height: 140,
                  child: Container(
                    color: const Color.fromARGB(32, 0, 159, 195),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(task.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                  ),
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
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 12.0),
                              child: Row(children: [
                                Text(
                                    task.workDuration
                                        .toString()
                                        .split('.')
                                        .first
                                        .padLeft(8, '0'),
                                    style: const TextStyle(
                                        color: AppColors.primary)),
                                const SizedBox(width: 12.0),
                                SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                      value: task.estimation.isEmpty
                                          ? 0.5
                                          : task.workDuration.inSeconds /
                                              str2dur(task.estimation)
                                                  .inSeconds,
                                      minHeight: 10.0,
                                      backgroundColor: AppColors.lightGrey),
                                ),
                                const SizedBox(width: 12.0),
                                Text(task.estimation.isEmpty
                                    ? 'N/A'
                                    : task.estimation)
                              ]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: handleStartTask,
                                    child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.play_arrow,
                                              color: Colors.white),
                                          SizedBox(width: 4.0),
                                          Text("Start",
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ])),
                              ],
                            )
                          ]),
                    ),
                  ),
                )),
    );
  }

  Duration str2dur(String time) {
    List<String> arr = time.split(':');
    return Duration(
        hours: int.parse(arr[0]),
        minutes: int.parse(arr[1]),
        seconds: int.parse(arr[2]));
  }
}

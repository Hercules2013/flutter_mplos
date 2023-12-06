import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';

// ignore: must_be_immutable
class MiniTaskItem extends ConsumerStatefulWidget {
  Task task;
  MiniTaskItem(this.task, {super.key});

  @override
  ConsumerState<MiniTaskItem> createState() => _MiniTaskItemState();
}

class _MiniTaskItemState extends ConsumerState<MiniTaskItem> {
  Task get task => widget.task;
  bool isOpened = false;

  void handleToggleOpen() {
    setState(() {
      isOpened = !isOpened;
    });
  }

  void handleStartTask() {}

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
                        padding: const EdgeInsets.all(12.0),
                        child: Text(task.name)),
                  ],
                )
              : SizedBox(
                  height: 140,
                  child: Container(
                    color: const Color.fromARGB(32, 0, 159, 195),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: AppColors.lightGrey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8.0),
                                  Icon(
                                    Icons.open_in_new,
                                    color: AppColors.lightGrey,
                                    size: 20,
                                  )
                                ]),
                            Text(task.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontSize: 16)),
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
}

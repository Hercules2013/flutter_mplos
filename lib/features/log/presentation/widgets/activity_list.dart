import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/log/presentation/providers/log_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:data_table_2/data_table_2.dart';

class ActivityList extends ConsumerStatefulWidget {
  const ActivityList({super.key});

  @override
  ConsumerState<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends ConsumerState<ActivityList> {
  String searchText = "";
  TextEditingController processController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final logState = ref.watch(logStateNotifierProvider);

    List<Software> activities = logState.softwares;
    SoftwareConcreteState filter = logState.filter;

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 19, right: 19, top: 14, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("My Activity",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.black, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text("(${activities.length} Total)",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightGrey,
                          fontWeight: FontWeight.w400))
                ],
              ),
              SearchBar(
                constraints: const BoxConstraints(maxWidth: 290, maxHeight: 35),
                hintText: "Search",
                elevation: const MaterialStatePropertyAll(0),
                shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)))),
                backgroundColor:
                    const MaterialStatePropertyAll(Color(0xfff4f4f7)),
                hintStyle: MaterialStatePropertyAll(
                  Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: const Color(0x73000000)),
                ),
                textStyle: MaterialStatePropertyAll(Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black)),
                trailing: const [
                  Padding(
                    padding: EdgeInsets.only(right: 2, top: 0),
                    child:
                        Icon(Icons.search, color: Color(0xff868688), size: 18),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                padding: const MaterialStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
              ),
            ],
          ),
        ),
        const Divider(
          thickness: 1,
          color: AppColors.extraLightGrey,
          height: 1,
        ),
        Expanded(
          child: ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(const Color(0xffC4C4C4)),
            ),
            child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 32,
                minWidth: 600,
                headingRowHeight: 30,
                dataRowHeight: 66.5,
                isVerticalScrollBarVisible: true,
                isHorizontalScrollBarVisible: true,
                headingTextStyle: Theme.of(context).textTheme.bodyMedium,
                columns: const [
                  DataColumn2(label: Text('Application'), size: ColumnSize.L),
                  DataColumn(label: Text('Start')),
                  DataColumn(label: Text('Total Usage')),
                  DataColumn(label: Text('Status')),
                ],
                border: const TableBorder(
                    bottom: BorderSide(color: AppColors.extraLightGrey),
                    horizontalInside:
                        BorderSide(color: AppColors.extraLightGrey)),
                rows: activities
                    .where((activity) => activity.title
                        .toUpperCase()
                        .contains(searchText.toUpperCase()))
                    .where((activity) => filter == SoftwareConcreteState.all
                        ? true
                        : activity.state == filter)
                    .map((activity) => DataRow(cells: [
                          DataCell(Row(
                            children: [
                              File(activity.icon).existsSync()
                                  ? Image.file(File(activity.icon), width: 28)
                                  : const Icon(Icons.window_sharp,
                                      color: AppColors.primary, size: 28),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 150,
                                child: Text(activity.title,
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.fade),
                              )
                            ],
                          )),
                          DataCell(Text(activity.startTime,
                              style: const TextStyle(fontSize: 16))),
                          DataCell(Text(formatTime(activity.usage),
                              style: const TextStyle(fontSize: 16))),
                          DataCell(() {
                            switch (activity.state) {
                              case SoftwareConcreteState.waiting:
                                return const Text("Waiting approval",
                                    style: TextStyle(color: Color(0xFFFFB800)));
                              case SoftwareConcreteState.approved:
                                return const Text("Approved app",
                                    style: TextStyle(color: Color(0xFF00CB66)));
                              case SoftwareConcreteState.rejected:
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Rejected",
                                          style: TextStyle(
                                              color: Color(0xFFFF3535))),
                                      // const SizedBox(height: 8),
                                      // InkWell(
                                      //     onTap: () {
                                      //       requestProgram(activity.title);
                                      //     },
                                      //     child: const Text("Ask again",
                                      //         style: TextStyle(
                                      //             color: Color(0xFF00A4D8),
                                      //             decoration: TextDecoration
                                      //                 .underline)))
                                    ]);
                              default:
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Not set as work related",
                                          style: TextStyle(
                                              color: Color(0xFF828282))),
                                      const SizedBox(height: 8),
                                      InkWell(
                                          onTap: () {
                                            requestProgram(activity.title);
                                          },
                                          child: const Text("Ask to add",
                                              style: TextStyle(
                                                  color: Color(0xFF00A4D8),
                                                  decoration: TextDecoration
                                                      .underline)))
                                    ]);
                            }
                          }()),
                        ]))
                    .toList(),
                empty: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Icon(Icons.local_activity_rounded,
                          color: AppColors.lightGrey, size: 80),
                      Text("No Activities",
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                  color: AppColors.lightGrey,
                                  fontWeight: FontWeight.normal)),
                      const SizedBox(height: 120)
                    ]))),
          ),
        )
      ]),
    );
  }

  String formatDate(DateTime dateTime) {
    // dateTime = dateTime.subtract(DateTime.now().timeZoneOffset);
    // DateTime dateTime = dateTime1.subtract(Duration(minutes: 2));
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  String formatTime(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}min";
  }

  void requestProgram(String software) {
    processController.text = software;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.white,
              shadowColor: AppColors.extraLightGrey,
              child: SizedBox(
                width: 300,
                height: 150,
                child: Column(
                  children: [
                    Container(
                        width: 320,
                        color: AppColors.primary,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text("Edit Process Name",
                            style: TextStyle(color: Colors.white))),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                          controller: processController,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2.0),
                                borderRadius: BorderRadius.circular(4.0)),
                          )),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          ref
                              .read(logStateNotifierProvider.notifier)
                              .requestProgram(processController.text);
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(AppColors.primary)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Ask to Add",
                              style: TextStyle(color: Colors.white)),
                        )),
                  ],
                ),
              ));
        });
  }
}

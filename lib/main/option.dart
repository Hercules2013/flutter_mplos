import 'dart:convert';
import 'dart:developer';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/widgets/chat/avatar.dart';

class StatusItem {
  int value = -1;
  Color color = Colors.black;
  String label = '';

  StatusItem(this.value, this.label, this.color);
}

class OptionApp extends ConsumerStatefulWidget {
  final String feedData;
  const OptionApp(this.feedData, {Key? key}) : super(key: key);

  @override
  OptionAppState createState() => OptionAppState();
}

class OptionAppState extends ConsumerState<OptionApp> {
  ScrollController scrollController = ScrollController();

  String get feedData => widget.feedData;

  bool isSwitching = false;
  Company? selectedCompany;
  StatusItem curStatus = StatusItem(-1, '', Colors.black);

  List<StatusItem> statusArr = [
    StatusItem(1, 'Online', const Color(0xFF00CB66)),
    // StatusItem(2, 'On a break', const Color(0xFFFFB800)),
    StatusItem(3, 'On a break', const Color(0xFFFFB800)),
    // StatusItem(4, 'Offline', const Color(0xFFFF3535)),
    StatusItem(0, 'Offline', const Color(0xFFFF3535)),
  ];

  @override
  void initState() {
    super.initState();

    var jsonData = jsonDecode(feedData);
    Future.delayed(Duration.zero, () {
      ref.read(timerStateNotifierProvider.notifier).setToken(jsonData['token']);
      ref
          .read(timerStateNotifierProvider.notifier)
          .selectCompany(Company.fromJson(jsonData['activeCompany']));
      ref.read(timerStateNotifierProvider.notifier).setCompanies(
          (jsonData['companies'] as List<dynamic>)
              .map((el) => Company.fromJson(el))
              .toList());
      ref
          .read(timerStateNotifierProvider.notifier)
          .setUserStatus(jsonData['userStatus']);
      ref
          .read(timerStateNotifierProvider.notifier)
          .setStartWorkTime(jsonData['startWorkTime']);

      if (jsonData['lastTask'].toString() != 'null') {
        ref
            .read(timerStateNotifierProvider.notifier)
            .setLastTask(Task.fromJson(jsonData['lastTask']));
      }

      setState(() {
        selectedCompany = Company.fromJson(jsonData['activeCompany']);
      });

      if (jsonData['userStatus'] == 1) {
        curStatus = statusArr[0];
      } else if (jsonData['userStatus'] == 2 || jsonData['userStatus'] == 3) {
        curStatus = statusArr[1];
      } else if (jsonData['userStatus'] == 0 || jsonData['userStatus'] == 4) {
        curStatus = statusArr[2];
      }
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
    final jsonData = jsonDecode(call.arguments.toString());

    switch (jsonData['div']) {
      case 'refreshUserStatus':
        int status = int.parse(jsonData['cust_msg'].toString());
        String id = jsonData['sender_id'].toString();
        if (ref.read(timerStateNotifierProvider).activeCompany.userID == id) {
          handleChangeUserStatus(
              statusArr.where((el) => el.value == status).first);
          ref.read(timerStateNotifierProvider.notifier).setUserStatus(status);
        }
        break;
      case 'startDayWithMission':
      case 'taskChangeInTimer':
        ref.read(timerStateNotifierProvider.notifier).setActiveTask(ref
            .read(timerStateNotifierProvider)
            .tasks
            .where((task) => task.id == int.parse(jsonData['cust_msg']))
            .first);
        // setState(() {
        //   dayStartedTime = jsonData['']
        // });
        break;
    }
  }

  void toggleCompanyPanel() {
    // final timerState = ref.read(timerStateNotifierProvider);
    // log(timerState.tasks.toString());
    setState(() {
      isSwitching = !isSwitching;
    });
  }

  void handleOpenInBrowser() {
    // log(ref.read(timerStateNotifierProvider).token);
    // ref.read(timerStateNotifierProvider.notifier).openInBrowser();
    launchUrl(Uri.parse('https://mplos.com'));
    // DesktopMultiWindow.invokeMethod(0, 'child_event',
    //     jsonEncode({'type': 'launchURL', 'url': 'https://mplos.com'}));
  }

  void handleSignOut() {
    // ref.read(timerStateNotifierProvider.notifier).signOut();
    DesktopMultiWindow.invokeMethod(
        0, 'child_event', jsonEncode({'type': 'signout'}));
  }

  void handleQuit() async {
    // log('Quit');
    // ref.read(timerStateNotifierProvider.notifier).quit();
    // appWindow.close();
    DesktopMultiWindow.invokeMethod(
        0, 'child_event', jsonEncode({'type': 'close'}));
  }

  handleChangeUserStatus(StatusItem? item) {
    setState(() {
      curStatus = item!;
      ref.read(timerStateNotifierProvider.notifier).setUserStatus(item.value);
    });
  }

  handleOpenTask() {
    final timerState = ref.read(timerStateNotifierProvider);
    if (timerState.lastTask != null) {
      log('Open Task URL :: ${timerState.lastTask!.link}');
      launchUrl(Uri.parse(timerState.lastTask!.link));
    }
  }

  handleSwitchCompany(Company company) {
    // ref.read(timerStateNotifierProvider.notifier).switchCompany(company.id);
    DesktopMultiWindow.invokeMethod(0, 'child_event',
        jsonEncode({'type': 'switch_company', 'company_id': company.id}));
    setState(() {
      selectedCompany = company;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateNotifierProvider);

    final textStyle = GoogleFonts.dmSans(
        color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: !isSwitching
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 16.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Avatar(
                              User(
                                  name: timerState.activeCompany.userName,
                                  type: 'user',
                                  avatar: timerState.activeCompany.userProfile,
                                  unReadCount: -1),
                              20,
                              false),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(timerState.activeCompany.name,
                                  style: textStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4.0),
                              Text(timerState.activeCompany.permission,
                                  style: textStyle.copyWith(fontSize: 15)),
                              const SizedBox(height: 8.0),
                              InkWell(
                                  onTap: toggleCompanyPanel,
                                  child: Text("Switch company",
                                      style: textStyle.copyWith(
                                          color: AppColors.primary,
                                          decoration:
                                              TextDecoration.underline)))
                            ],
                          ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                        width: double.infinity,
                        height: 1,
                        color: AppColors.lightGrey),
                  ),
                  Column(children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Status", style: textStyle),
                              PopupMenuButton<StatusItem>(
                                  onSelected: handleChangeUserStatus,
                                  offset: const Offset(0, 50),
                                  itemBuilder: (_) {
                                    return statusArr
                                        .map((status) =>
                                            PopupMenuItem<StatusItem>(
                                                value: status,
                                                child: Text(status.label,
                                                    style: textStyle.copyWith(
                                                        color: status.color))))
                                        .toList();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 12.0),
                                    child: Row(children: [
                                      Text(curStatus.label,
                                          style: textStyle.copyWith(
                                              color: curStatus.color)),
                                      const Icon(Icons.chevron_right)
                                    ]),
                                  )),
                              // DropdownMenu(
                              //     initialSelection: curStatus,
                              //     onSelected: handleChangeUserStatus,
                              //     trailingIcon: const Icon(Icons.chevron_right),
                              //     inputDecorationTheme: const InputDecorationTheme(
                              //         border: InputBorder.none,
                              //         contentPadding: EdgeInsets.zero,
                              //         constraints: BoxConstraints(
                              //             minWidth: 0, maxWidth: 125)),
                              //     textStyle: textStyle.copyWith(
                              //         color: curStatus.color),
                              //     requestFocusOnTap: false,
                              //     dropdownMenuEntries: statusArr
                              //         .map((status) => DropdownMenuEntry(
                              //             value: status,
                              //             label: status.label,
                              //             style: ButtonStyle(
                              //                 foregroundColor:
                              //                     MaterialStateProperty.all(
                              //                         status.color),
                              //                 elevation:
                              //                     MaterialStateProperty.all(
                              //                         0.0),
                              //                 fixedSize:
                              //                     MaterialStateProperty.all(
                              //                         const Size(120, 40)),
                              //                 textStyle:
                              //                     MaterialStateProperty.all(
                              //                         GoogleFonts.dmSans(
                              //                             fontSize: 14)))))
                              //         .toList()),

                              // DropdownButton(items: items, onChanged: onChanged)
                              // Text("Online",
                              //     style:
                              //         textStyle.copyWith(color: Colors.green))
                            ])),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, bottom: 8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Day started", style: textStyle),
                              Text(timerState.startWorkTime,
                                  style: textStyle.copyWith(
                                      color: AppColors.lightGrey))
                            ])),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Last task", style: textStyle),
                            SizedBox(
                              width: 120,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: handleOpenTask,
                                  child: Text(
                                      timerState.lastTask == null
                                          ? 'No task'
                                          : timerState.lastTask!.name,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: textStyle.copyWith(
                                          color: AppColors.lightGrey,
                                          decoration:
                                              TextDecoration.underline)),
                                ),
                              ),
                            )
                          ]),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                        width: double.infinity,
                        height: 1,
                        color: AppColors.lightGrey),
                  ),
                  Column(children: [
                    InkWell(
                        onTap: handleOpenInBrowser,
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Text("Open in browser", style: textStyle))),
                    InkWell(
                        onTap: handleSignOut,
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Text("Sign Out", style: textStyle))),
                    InkWell(
                        onTap: handleQuit,
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Text("Quit",
                                style: textStyle.copyWith(color: Colors.red))))
                  ])
                ])
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: toggleCompanyPanel,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.arrow_back),
                                  const SizedBox(width: 8.0),
                                  Text("Back",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 16))
                                ])),
                        const SizedBox(height: 8.0),
                        Expanded(
                            child: SingleChildScrollView(
                                controller: scrollController,
                                child: Column(
                                  children: timerState.companies
                                      .map((company) => InkWell(
                                            onTap: () =>
                                                handleSwitchCompany(company),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      Avatar(
                                                          User(
                                                              avatar: company
                                                                  .userProfile,
                                                              name: company
                                                                  .userName,
                                                              color: company
                                                                  .userName,
                                                              unReadCount: -1),
                                                          20,
                                                          true),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(company.name,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          16)),
                                                          company.permission !=
                                                                  'null'
                                                              ? Text(company
                                                                  .permission)
                                                              : const SizedBox
                                                                  .shrink(),
                                                        ],
                                                      ),
                                                    ]),
                                                    selectedCompany == company
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.green)
                                                        : const SizedBox
                                                            .shrink()
                                                  ]),
                                            ),
                                          ))
                                      .toList(),
                                )))
                      ])),
        ),
      ),
    );
  }
}

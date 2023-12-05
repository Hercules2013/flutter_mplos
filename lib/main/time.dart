import 'dart:convert';
import 'dart:developer';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/theme/app_theme.dart';

class TimeApp extends ConsumerStatefulWidget {
  final String feedData;
  const TimeApp(this.feedData, {Key? key}) : super(key: key);

  @override
  TimeAppState createState() => TimeAppState();
}

class TimeAppState extends ConsumerState<TimeApp> with WidgetsBindingObserver {
  String get feedData => widget.feedData;

  @override
  void initState() {
    super.initState();

    final jsonData = jsonDecode(feedData);

    String token = jsonData['token'];
    Company activeCompany = Company.fromJson(jsonData['activeCompany']);
    String timerStatus = jsonData['timerStatus'];

    Future.delayed(Duration.zero, () {
      ref.read(timerStateNotifierProvider.notifier).setToken(token);
      ref
          .read(timerStateNotifierProvider.notifier)
          .selectCompany(activeCompany);
      ref.read(timerStateNotifierProvider.notifier).setTimerStatus(timerStatus);
    });

    DesktopMultiWindow.setMethodHandler(_handleMethodCallback);
  }

  @override
  dispose() {
    DesktopMultiWindow.setMethodHandler(null);
    super.dispose();
  }

  void handleEndDay() {
    ref.read(timerStateNotifierProvider.notifier).endDay().then((_) {
      ref.read(timerStateNotifierProvider.notifier).sendReport();
      DesktopMultiWindow.invokeMethod(
          0,
          'child_event',
          jsonEncode({
            'type': 'switch_company',
            'company_id': ref.read(timerStateNotifierProvider).activeCompany.id
          }));
    });
  }

  void handlePauseResumeWork() {
    final timerState = ref.read(timerStateNotifierProvider);
    String option = timerState.timerStatus == 'active' ? 'breake' : 'resume';
    ref.read(timerStateNotifierProvider.notifier).pauseResumeWork(option);
  }

  Future<dynamic> _handleMethodCallback(
      MethodCall call, int fromWindowId) async {
    final jsonData = jsonDecode(call.arguments.toString());

    switch (jsonData['div']) {
      case 'takeBreak':
      case 'resumeWork':
        ref.read(timerStateNotifierProvider.notifier).setTimerStatus(
            jsonData['div'] == 'resumeWork' ? 'active' : 'not_active');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateNotifierProvider);
    final normalTextStyle = GoogleFonts.dmSans(
        fontSize: 14,
        color: const Color(0xff595454),
        fontWeight: FontWeight.w500);

    bool isWorking = timerState.timerStatus == 'active';

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(children: [
                InkWell(
                    onTap: handleEndDay,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.power_settings_new,
                                color: Colors.red, size: 20),
                            const SizedBox(width: 8.0),
                            Text("End the day", style: normalTextStyle),
                            const SizedBox(width: 2.0)
                          ]),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Container(
                      width: double.infinity,
                      height: 1.0,
                      color: AppColors.lightGrey),
                ),
                InkWell(
                    onTap: handlePauseResumeWork,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            !isWorking
                                ? const Icon(Icons.play_arrow,
                                    color: Colors.blueGrey, size: 20)
                                : const Icon(Icons.coffee,
                                    color: Color(0xffffb800), size: 20),
                            const SizedBox(width: 8.0),
                            Text(!isWorking ? "Resume work" : "Take a break",
                                style: normalTextStyle),
                            const SizedBox(width: 2.0)
                          ]),
                    )),
              ]),
            )));
  }
}

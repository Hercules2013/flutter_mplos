import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tray_manager/tray_manager.dart';

import 'package:mplos_chat/shared/theme/app_theme.dart';

import '../routes/timer_route.dart';

class MainApp extends ConsumerStatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends ConsumerState<MainApp> with TrayListener {
  final timerRouter = TimerRouter();

  @override
  void initState() async {
    super.initState();

    trayManager.addListener(this);

    // Set java_exit_flag to true so java process will be killed automatically
    final Directory dir = await getApplicationDocumentsDirectory();
    String filePath =
        "${dir.path.toString().replaceAll('Documents', 'mplos')}\\java.cnf";
    String content = File(filePath).readAsStringSync();
    content = content.isEmpty ? '{}' : content;
    final jsonData = jsonDecode(content);
    jsonData['java_exit_flag'] = false;
    File(filePath).writeAsStringSync(jsonEncode(jsonData));
  }

  @override
  void dispose() async {
    trayManager.removeListener(this);
    super.dispose();

    // Set java_exit_flag to true so java process will be killed automatically
    final Directory dir = await getApplicationDocumentsDirectory();
    String filePath =
        "${dir.path.toString().replaceAll('Documents', 'mplos')}\\java.cnf";
    String content = File(filePath).readAsStringSync();
    final jsonData = jsonDecode(content);
    jsonData['java_exit_flag'] = true;
    File(filePath).writeAsStringSync(jsonEncode(jsonData));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mplos Timer',
      theme: AppTheme.lightTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.windows: NoShadowCupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: NoShadowCupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: NoShadowCupertinoPageTransitionsBuilder(),
      })),
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routeInformationParser: timerRouter.defaultRouteParser(),
      routerDelegate: timerRouter.delegate(),
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void onTrayIconMouseDown() {}

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {}

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        appWindow.show();
        break;
      case 'exit_app':
        appWindow.close();
        break;
    }
  }
}

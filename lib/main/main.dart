import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  void initState() {
    super.initState();

    trayManager.addListener(this);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
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

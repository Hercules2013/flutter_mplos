import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:mplos_chat/main/main.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';

import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

import 'package:mplos_chat/main/option.dart';
import 'package:mplos_chat/main/task.dart';
import 'package:mplos_chat/main/time.dart';
import 'package:mplos_chat/main/chat.dart';
import 'package:mplos_chat/main/observers.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (args.firstOrNull == 'multi_window') {
    Widget? childWidget;

    var jsonData = jsonDecode(args[2]);
    switch (jsonData['type']) {
      case "Menu":
        childWidget = OptionApp(args[2]);
        break;
      case "Taskbar":
        childWidget = TaskApp(args[2]);
        break;
      case "Timer":
        childWidget = TimeApp(args[2]);
        break;
      case "Chat":
        childWidget = ChatApp(args[2]);
        break;
    }

    WindowOptions windowOptions = WindowOptions(
        skipTaskbar: jsonData['type'] != "Chat",
        titleBarStyle: jsonData['type'] != "Chat"
            ? TitleBarStyle.hidden
            : TitleBarStyle.normal);
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setTitle("Mplos ${jsonData['type']}");
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(true);
      await windowManager.setMaximizable(false);
      await windowManager.setClosable(false);
      // await windowManager.show();

      runApp(ProviderScope(
        observers: [
          Observers(),
        ],
        overrides: const [],
        child: childWidget!,
      ));
    });
  } else {
    await localNotifier.setup(
      appName: 'Mplos App',
      // The parameter shortcutPolicy only works on Windows
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );

    WindowOptions windowOptions = const WindowOptions(
        title: "Mplos Timer",
        skipTaskbar: false,
        alwaysOnTop: true,
        titleBarStyle: TitleBarStyle.hidden,
        size: Size(380, 500));
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAlignment(Alignment.bottomRight);
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(true);
      await windowManager.show();

      runApp(ProviderScope(
        observers: [
          Observers(),
        ],
        overrides: const [],
        child: const MainApp(),
      ));

      await trayManager.setIcon(
        'assets/images/mplos.ico',
      );
      Menu menu = Menu();
      menu.items = [
        MenuItem(
          key: 'show_window',
          label: 'Show Window',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
        ),
      ];
      await trayManager.setContextMenu(menu);
    });
  }
}

// https://github.com/MixinNetwork/flutter-plugins/issues/137
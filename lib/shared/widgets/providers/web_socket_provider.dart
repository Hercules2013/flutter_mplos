import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final webSocketChannelProvider = Provider<WebSocketChannel>((ref) {
  String companyName = ref.read(timerStateNotifierProvider).activeCompany.name;
  String userID = ref.read(timerStateNotifierProvider).activeCompany.userID;

  String webSocketURL =
      'wss://socket.xite.io:9006/?id=$companyName-desktop-$userID-';

  log('WebSocket :: $webSocketURL');

  HttpOverrides.global = MyHttpOverrides();

  return WebSocketChannel.connect(Uri.parse(webSocketURL), protocols: {});
});

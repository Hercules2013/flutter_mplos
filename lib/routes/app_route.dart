import 'package:auto_route/auto_route.dart';

import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/log/presentation/screens/log_screen.dart';
import '../features/timer/presentation/screens/timer_screen.dart';
import '../features/timer/presentation/screens/mission_screen.dart';
import '../features/timer/presentation/screens/control_screen.dart';

part 'app_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/chat', page: ChatRoute.page, initial: true),
        AutoRoute(path: '/log', page: LogRoute.page),
      ];
}

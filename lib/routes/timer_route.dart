import 'package:auto_route/auto_route.dart';

import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/log/presentation/screens/log_screen.dart';
import '../features/timer/presentation/screens/timer_screen.dart';
import '../features/timer/presentation/screens/mission_screen.dart';
import '../features/timer/presentation/screens/control_screen.dart';

part 'timer_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class TimerRouter extends _$TimerRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', page: TimerRoute.page, initial: true),
        AutoRoute(path: '/select-mission', page: MissionRoute.page),
        AutoRoute(path: '/timer', page: ControlRoute.page),
      ];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'timer_route.dart';

abstract class _$TimerRouter extends RootStackRouter {
  // ignore: unused_element
  _$TimerRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    ChatRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChatScreen(),
      );
    },
    LogRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LogScreen(),
      );
    },
    ControlRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ControlScreen(),
      );
    },
    MissionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MissionScreen(),
      );
    },
    TimerRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TimerScreen(),
      );
    },
  };
}

/// generated route for
/// [ChatScreen]
class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
      : super(
          ChatRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LogScreen]
class LogRoute extends PageRouteInfo<void> {
  const LogRoute({List<PageRouteInfo>? children})
      : super(
          LogRoute.name,
          initialChildren: children,
        );

  static const String name = 'LogRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ControlScreen]
class ControlRoute extends PageRouteInfo<void> {
  const ControlRoute({List<PageRouteInfo>? children})
      : super(
          ControlRoute.name,
          initialChildren: children,
        );

  static const String name = 'ControlRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MissionScreen]
class MissionRoute extends PageRouteInfo<void> {
  const MissionRoute({List<PageRouteInfo>? children})
      : super(
          MissionRoute.name,
          initialChildren: children,
        );

  static const String name = 'MissionRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TimerScreen]
class TimerRoute extends PageRouteInfo<void> {
  const TimerRoute({List<PageRouteInfo>? children})
      : super(
          TimerRoute.name,
          initialChildren: children,
        );

  static const String name = 'TimerRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

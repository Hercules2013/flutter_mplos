import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';

import './auth_screen.dart';
import './company_screen.dart';

@RoutePage()
class TimerScreen extends ConsumerStatefulWidget {
  static const String routeName = 'TimerScreen';

  const TimerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    bool isAuth = ref.watch(timerStateNotifierProvider).token.isEmpty;

    return isAuth ? const AuthScreen() : const CompanyScreen();
  }
}

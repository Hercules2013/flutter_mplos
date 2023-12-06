import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mplos_chat/features/timer/domain/repositories/timer_repository.dart';
import 'package:mplos_chat/features/timer/domain/providers/timer_provider.dart';
import 'package:mplos_chat/features/timer/presentation/providers/state/timer_notifier.dart';
import 'package:mplos_chat/features/timer/presentation/providers/state/timer_state.dart';

final timerStateNotifierProvider =
    StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final TimerRepository timerRepository = ref.watch(timerRepositoryProvider);
  return TimerNotifier(timerRepository: timerRepository);
});

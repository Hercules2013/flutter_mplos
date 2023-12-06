import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/log/domain/providers/log_provider.dart';
import 'package:mplos_chat/features/log/domain/repositories/log_repository.dart';
import 'package:mplos_chat/features/log/presentation/providers/state/log_notifier.dart';
import 'package:mplos_chat/features/log/presentation/providers/state/log_state.dart';

final logStateNotifierProvider =
    StateNotifierProvider<LogNotifier, LogState>((ref) {
  final LogRepository logRepository = ref.watch(logRepositoryProvider);
  return LogNotifier(logRepository: logRepository);
});

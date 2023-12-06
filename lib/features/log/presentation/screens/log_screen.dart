import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/log/presentation/providers/log_state_provider.dart';

import 'package:mplos_chat/shared/widgets/main_layout.dart';

import '../widgets/activity_filter.dart';
import '../widgets/activity_list.dart';

@RoutePage()
class LogScreen extends ConsumerStatefulWidget {
  static const String routeName = 'LogScreen';

  const LogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    ref.read(logStateNotifierProvider.notifier).saveActivity(
        ref.read(logStateNotifierProvider).softwares, DateTime.now());    
  }

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
        child:
            Row(children: [ActivityFilter(), Expanded(child: ActivityList())]));
  }
}

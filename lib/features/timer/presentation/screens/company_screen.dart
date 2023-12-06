import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/features/timer/presentation/widgets/company_item.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:window_manager/window_manager.dart';

// @RoutePage()
class CompanyScreen extends ConsumerStatefulWidget {
  static const String routeName = 'CompanyScreen';

  const CompanyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WindowManager.instance.setSize(const Size(380, 500));
    WindowManager.instance.setAlignment(Alignment.bottomRight);
  }

  void handleStartDrag(details) {
    appWindow.startDragging();
  }

  void handleClose() {
    appWindow.close();
  }

  void handleSignin() {
    ref.read(timerStateNotifierProvider.notifier).getMissions().then((_) {
      final timerState = ref.read(timerStateNotifierProvider);
      List<Task> tasks = timerState.tasks;
      for (Task task in tasks) {
        ref.read(timerStateNotifierProvider.notifier).getMissionStatus(task.id);
      }
      goToURL('/select-mission');
    });
  }

  void handleSignout() {
    ref.read(timerStateNotifierProvider.notifier).logOut();
    ref.read(timerStateNotifierProvider.notifier).saveCredential('null');
  }

  @override
  Widget build(BuildContext context) {
    final headerTextStyle =
        GoogleFonts.pacifico(fontSize: 14, color: Colors.white);

    String username = ref.watch(timerStateNotifierProvider).username;
    List<Company> companies = ref.watch(timerStateNotifierProvider).companies;

    return Scaffold(
        body: Column(children: [
      GestureDetector(
        onPanStart: handleStartDrag,
        child: Container(
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(children: [
                      const Icon(Icons.window),
                      const SizedBox(width: 6.0),
                      Text("Mplos.com", style: headerTextStyle),
                    ]),
                  ),
                  IconButton(
                      onPressed: handleClose, icon: const Icon(Icons.close))
                ]),
          ),
        ),
      ),
      Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("Hello, $username, Please select company:",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.lightGrey)),
        ),
        SizedBox(
          height: 300,
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbVisibility: MaterialStateProperty.all(true),
                thumbColor: MaterialStateProperty.all(
                    AppColors.primary), // Replace with your desired color
              ),
            ),
            child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children:
                      companies.map((company) => CompanyItem(company)).toList(),
                )),
          ),
        )
      ]),
      Container(
          width: double.infinity, height: 1.0, color: AppColors.lightGrey),
      const SizedBox(height: 24.0),
      ElevatedButton(
          onPressed: handleSignin,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.login, color: AppColors.white),
              const SizedBox(width: 8.0),
              Text("LOG IN",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 15, color: AppColors.white))
            ]),
          )),
      const SizedBox(height: 8.0),
      InkWell(
          onTap: handleSignout,
          child: Text("Logout",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.lightGrey)))
    ]));
  }

  void goToURL(url) async {
    AutoRouter.of(context).replaceNamed(url);
    await WindowManager.instance.setAlignment(Alignment.bottomRight);
  }
}

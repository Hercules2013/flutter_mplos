import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';

import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

// @RoutePage()
class AuthScreen extends ConsumerStatefulWidget {
  static const String routeName = 'AuthScreen';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  bool isRemembered = false;

  @override
  void initState() {
    super.initState();

    WindowManager.instance.setSize(const Size(380, 500));
    WindowManager.instance.setAlignment(Alignment.bottomRight);

    Future.delayed(Duration.zero, () {
      ref
          .read(timerStateNotifierProvider.notifier)
          .getCredential()
          .then((value) {
        if (value.toString() == 'null') return;
        final data = jsonDecode(value);
        emailController.text = data['username'];
        passwordController.text = data['password'];
        handleSignin(data['username'].toString(), data['password'].toString());
      });
    });
  }

  void handleStartDrag(details) {
    appWindow.startDragging();
  }

  void handleClose() async {
    appWindow.close();
  }

  void handleForgotPassword() {
    launchUrl(Uri.parse('https://mplos.com/Forgot_password'));
  }

  void handleSignin(String username, String password) async {
    // https://mplos.com/api.php?api=login&username=parastc&password=pass0364
    ref
        .read(timerStateNotifierProvider.notifier)
        .signIn(username, password)
        .then((value) {
      if (isRemembered) {
        final credential = jsonEncode({
          'username': username,
          'password': password,
        });
        ref
            .read(timerStateNotifierProvider.notifier)
            .saveCredential(credential);
      }
      ref.read(timerStateNotifierProvider.notifier).getCompanySetting();
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerTextStyle =
        GoogleFonts.pacifico(fontSize: 14, color: Colors.white);

    final timerState = ref.watch(timerStateNotifierProvider);

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
      Expanded(
          child: Container(
              color: Colors.black38,
              child: Center(
                  child: Container(
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.0)),
                margin: const EdgeInsets.only(bottom: 24.0),
                child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: SizedBox(
                      width: 260,
                      height: 225,
                      child: Column(children: [
                        TextField(
                            controller: emailController,
                            enabled: !timerState.isLoading,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.black),
                            decoration: const InputDecoration(
                                hintText: 'Enter username here',
                                hintStyle: TextStyle(
                                    color: AppColors.lightGrey, fontSize: 13),
                                icon: Icon(Icons.person_2_outlined,
                                    color: AppColors.primary))),
                        TextField(
                            controller: passwordController,
                            enabled: !timerState.isLoading,
                            obscureText: true,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.black, fontSize: 20),
                            decoration: const InputDecoration(
                              hintText: 'Enter password here',
                              hintStyle: TextStyle(
                                  color: AppColors.lightGrey, fontSize: 13),
                              icon: Icon(Icons.lock_outline,
                                  color: AppColors.primary),
                            ),
                            onSubmitted: (value) {
                              handleSignin(emailController.text,
                                  passwordController.text);
                            }),
                        const SizedBox(height: 4.0),
                        timerState.errorMessage.isEmpty
                            ? const SizedBox.shrink()
                            : Text(timerState.errorMessage,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.redAccent)),
                        const SizedBox(height: 4.0),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isRemembered = !isRemembered;
                                  });
                                },
                                child: Row(children: [
                                  Checkbox(
                                      value: isRemembered,
                                      activeColor: AppColors.primary,
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                      onChanged: (value) {
                                        setState(() {
                                          isRemembered = value!;
                                        });
                                      },
                                      splashRadius: 0),
                                  Text("Remember Me",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Colors.black,
                                              fontSize: 14))
                                ]),
                              ),
                              InkWell(
                                  onTap: handleForgotPassword,
                                  child: const Text("Forgot Password?",
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)))
                            ]),
                        const SizedBox(height: 18.0),
                        ElevatedButton(
                            onPressed: timerState.isLoading
                                ? null
                                : () => handleSignin(emailController.text,
                                    passwordController.text),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.primary)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  timerState.isLoading
                                      ? const Row(children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                color: AppColors.white),
                                          ),
                                          SizedBox(width: 8.0),
                                        ])
                                      : const SizedBox.shrink(),
                                  Text("LOG IN",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: 15,
                                              color: AppColors.white)),
                                ],
                              ),
                            )),
                      ]),
                    )),
              ))))
    ]));
  }

  void goToURL(url) async {
    AutoRouter.of(context).navigateNamed(url);
  }
}

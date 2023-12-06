import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/features/chat/presentation/widgets/company_item.dart';
import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/widgets/chat/avatar.dart';
import 'package:mplos_chat/shared/widgets/providers/app_state_provider.dart';

import './sidebar_item.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  handleSwitchCompany(Company? company) {
    if (company == null) return;

    ref.read(timerStateNotifierProvider.notifier).selectCompany(company);
    DesktopMultiWindow.invokeMethod(0, 'child_event',
        jsonEncode({'type': 'switch_company', 'company_id': company.id}));
  }

  handleLogOut() {
    DesktopMultiWindow.invokeMethod(
        0, 'child_event', jsonEncode({'type': 'signout'}));
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateNotifierProvider);
    final timerState = ref.watch(timerStateNotifierProvider);
    final headerTextStyle =
        GoogleFonts.pacifico(fontSize: 14, color: const Color(0xFF00A0C3));

    final url = AutoRouter.of(context).urlState.path;

    return Container(
      width: 65,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color(0xfffafafa),
        border: BorderDirectional(
          end: BorderSide(
            width: 2,
            color: Color(0xffe9e9e9),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Text("mplos", style: headerTextStyle),
                Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: PopupMenuButton<Company>(
                        tooltip: '',
                        onSelected: handleSwitchCompany,
                        // initialValue: timerState.activeCompany,
                        itemBuilder: (_) {
                          return timerState.companies
                              .map((company) => PopupMenuItem(
                                  value: company, child: CompanyItem(company)))
                              .toList();
                        },
                        // constraints: const BoxConstraints(maxHeight: 300),
                        // position: PopupMenuPosition.under,
                        offset: const Offset(0, 60),
                        color: Colors.white,
                        // padding: EdgeInsets.zero,
                        child: Avatar(
                            User(
                                avatar: appState.profileUrl.toString(),
                                color: appState.profileColor.toString(),
                                name: appState.userName.toString(),
                                status: appState.userStatus,
                                unReadCount: 0),
                            18,
                            false,
                            badge: true))),
                const Divider(
                  indent: 10,
                  thickness: 2,
                  endIndent: 10,
                  height: 35,
                  color: Color(0xffe9e9e9),
                ),
                SidebarItem(
                    icon: Icons.chat,
                    text: 'Chat',
                    isActive: url == '/chat',
                    onPressed: () {
                      goToURL('/chat');
                    }),
                const SizedBox(height: 10),
                SidebarItem(
                    icon: Icons.call_outlined,
                    text: 'Calls',
                    isActive: false,
                    onPressed: () {
                      // goToURL('/calls');
                    }),
                const SizedBox(height: 10),
                SidebarItem(
                    icon: Icons.event_note,
                    text: 'Log',
                    isActive: url == '/log',
                    onPressed: () {
                      goToURL('/log');
                    }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Column(
              children: [
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(
                //     Icons.settings_outlined,
                //     color: Colors.grey,
                //   ),
                // ),
                IconButton(
                  onPressed: handleLogOut,
                  icon: const Icon(
                    Icons.logout_outlined,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void goToURL(url) async {
    AutoRouter.of(context).navigateNamed(url);
  }
}

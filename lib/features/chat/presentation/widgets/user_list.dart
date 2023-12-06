import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mplos_chat/features/chat/presentation/providers/chat_state_provider.dart';
import 'package:mplos_chat/features/chat/presentation/widgets/contacts.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';

class UserList extends ConsumerStatefulWidget {
  const UserList({super.key});

  @override
  ConsumerState<UserList> createState() => _UserListState();
}

class _UserListState extends ConsumerState<UserList> {
  String filter = '', sortBy = 'newest';
  TextEditingController sortController = TextEditingController();

  @override
  void initState() {
    super.initState();

    sortController.text = 'Newest';
  }

  @override
  Widget build(BuildContext context) {
    const options = [
      {'value': 'newest', 'label': 'Newest'},
      {'value': 'unread', 'label': 'Unread Messages'},
      {'value': 'name', 'label': 'By Name (A-Z)'},
    ];
    List<DropdownMenuEntry> sortLists = <DropdownMenuEntry>[];
    for (var element in options) {
      sortLists.add(DropdownMenuEntry(
          value: element['value'],
          label: element['label']!,
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(AppColors.black),
              textStyle: MaterialStateProperty.all(
                  GoogleFonts.dmSans(fontSize: 14, color: AppColors.black)))));
    }

    // final appState = ref.watch(appStateNotifierProvider);
    // List<String> titles = appState.tasks.map((e) => e.title).toList();
    // log(titles.toString());

    // missions.clear();

    // for (var element in titles) {
    //   log(element);

    //   missions.add(DropdownMenuEntry(
    //       value: 1,
    //       label: element,
    //       style: ButtonStyle(
    //           foregroundColor: MaterialStateProperty.all(AppColors.black),
    //           textStyle: MaterialStateProperty.all(
    //               GoogleFonts.dmSans(fontSize: 14, color: AppColors.black)))));
    // }

    return Container(
      decoration: const BoxDecoration(
          // color: Colors.blueAccent,
          border: Border(right: BorderSide(color: Colors.black12, width: 1.0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(left: 20, top: 15),
            child: SizedBox(
                height: 125,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 10),
                      child: Text(
                        "Messages",
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                                fontSize: 26, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Row(
                      children: [
                        SearchBar(
                            constraints: const BoxConstraints(
                              // maxWidth: 290,
                              maxWidth: 320,
                              maxHeight: 40,
                            ),
                            padding: const MaterialStatePropertyAll(
                                EdgeInsets.only(left: 10, bottom: 4.5)),
                            elevation: const MaterialStatePropertyAll(0),
                            shape: const MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)))),
                            backgroundColor: const MaterialStatePropertyAll(
                                Color(0xfff4f4f7)),
                            leading: const Padding(
                              padding: EdgeInsets.only(left: 2, top: 4),
                              child: Icon(Icons.search,
                                  color: Color(0xff868688), size: 18),
                            ),
                            hintText: "Search",
                            hintStyle: MaterialStatePropertyAll(
                              Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: const Color(0x73000000)),
                            ),
                            textStyle: MaterialStatePropertyAll(
                                Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.black)),
                            onChanged: handleSearchTextChanged),
                        // IconButton(
                        //     onPressed: newChat,
                        //     icon: const Icon(Icons.add,
                        //         size: 24, color: AppColors.lightGrey),
                        //     splashRadius: 18.0)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: [
                          const Text("Sort by"),
                          Transform.translate(
                            offset: const Offset(0, 1),
                            child: DropdownMenu(
                              controller: sortController,
                              dropdownMenuEntries: sortLists,
                              onSelected: handleSortChanged,
                              width: 165,
                              trailingIcon: Transform.translate(
                                offset: const Offset(0, -5),
                                child: const Icon(Icons.expand_more,
                                    color: AppColors.primary, size: 20),
                              ),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.primary),
                              inputDecorationTheme: const InputDecorationTheme(
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  constraints: BoxConstraints(maxHeight: 36),
                                  contentPadding: EdgeInsets.only(left: 4)),
                              requestFocusOnTap: false,
                              menuStyle: MenuStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero),
                                  backgroundColor: MaterialStateProperty.all(
                                      AppColors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))),
        ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: 350,
                minHeight: MediaQuery.of(context).size.height - 212,
                maxHeight: MediaQuery.of(context).size.height - 212),
            child: Contacts(filter: filter, sortBy: sortBy))
      ]),
    );
  }

  newChat() {
    // ref
    //     .read(chatStateNotifierProvider.notifier)
    //     .addUsers([User(id: '123', name: "Ben Alex")]);

    // final appNotifier = ref.read(appStateNotifierProvider.notifier);
    // Future.delayed(Duration.zero, () {
    //   appNotifier.setToken("SBCJ2Y8ZUO7UOR10EI5U");
    //   appNotifier.setUserID("1");
    //   appNotifier.setUserName("sonuaryan");
    //   appNotifier.setCompanyID("1");
    //   appNotifier.setCompanyName("mplos");
    // });
    // final appNotifier = ref.read(appStateNotifierProvider.notifier);
    // log(appNotifier.state.token.toString());

    // ref.read(chatStateNotifierProvider.notifier).fetchUsers();
  }

  void handleSearchTextChanged(value) {
    setState(() {
      filter = value;
    });
    ref.read(chatStateNotifierProvider.notifier).filterUsers(filter);
  }

  void handleSortChanged(value) {
    setState(() {
      sortBy = value;
    });
    ref.read(chatStateNotifierProvider.notifier).sortUsers(sortBy);

    // log(Utc2Gmt("null"));
  }

  // String Utc2Gmt(String value) {
  //   if (value == "null") return DateTime(0).toString();

  //   List<String> dateNums = value.split(RegExp(r'[^0-9]'));
  //   DateTime zeroGMT = DateTime(
  //       int.parse(dateNums[0]),
  //       int.parse(dateNums[1]),
  //       int.parse(dateNums[2]),
  //       int.parse(dateNums[3]),
  //       int.parse(dateNums[4]),
  //       int.parse(dateNums[5]));
  //   return zeroGMT.add(DateTime.now().timeZoneOffset).toString();
  // }
}

import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';

class AppState {
  final String token;
  final String userID;
  final String userName;
  final String companyID;
  final String companyName;
  final String profileUrl, profileColor;
  final List<Task> tasks;
  Task activeTask;
  Status userStatus;
  final String audioLink;

  AppState(
      {this.companyName = 'Company name',
      this.token = '',
      this.userID = '',
      this.companyID = '',
      this.userName = '',
      this.tasks = const [],
      this.activeTask = const Task(),
      this.profileUrl = '',
      this.profileColor = '',
      this.userStatus = Status.offline,
      this.audioLink = ''});

  AppState.initial(
      {this.companyName = 'Company name',
      this.token = '',
      this.userID = '',
      this.companyID = '',
      this.userName = '',
      this.tasks = const [],
      this.activeTask = const Task(),
      this.profileUrl = '',
      this.profileColor = '',
      this.userStatus = Status.offline,
      this.audioLink = ''});

  AppState copyWith(
      {String? companyName,
      String? token,
      String? userID,
      String? companyID,
      String? userName,
      List<Task>? tasks,
      Task? activeTask,
      String? profileUrl,
      String? profileColor,
      Status? userStatus,
      String? audioLink}) {
    return AppState(
        companyName: companyName ?? this.companyName,
        token: token ?? this.token,
        userID: userID ?? this.userID,
        companyID: companyID ?? this.companyID,
        userName: userName ?? this.userName,
        tasks: tasks ?? this.tasks,
        activeTask: activeTask ?? this.activeTask,
        profileUrl: profileUrl ?? this.profileUrl,
        profileColor: profileColor ?? this.profileColor,
        userStatus: userStatus ?? this.userStatus,
        audioLink: audioLink ?? this.audioLink);
  }
}

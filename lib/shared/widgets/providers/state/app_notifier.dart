import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';
import 'package:mplos_chat/shared/widgets/providers/state/app_state.dart';

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(AppState.initial());

  void setToken(String token) {
    state = state.copyWith(token: token);
  }

  void setUserID(String userID) {
    state = state.copyWith(userID: userID);
  }

  void setUserName(String userName) {
    state = state.copyWith(userName: userName);
  }

  void setUserStatus(String status) {
    Map<String, Status> statusArr = {
      '0': Status.offline,
      '1': Status.online,
      '2': Status.away,
      '3': Status.onbreak,
      '4': Status.oncall,
      'null': Status.onnull
    };
    state = state.copyWith(userStatus: statusArr[status]);
  }

  void setCompanyName(String companyName) {
    state = state.copyWith(companyName: companyName);
  }

  void setCompanyID(String companyID) {
    state = state.copyWith(companyID: companyID);
  }

  void setProfileUrl(String profileUrl) {
    state = state.copyWith(profileUrl: profileUrl);
  }

  void setProfileColor(String profileColor) {
    state = state.copyWith(profileColor: profileColor);
  }

  void setTasks(List<Task> tasks) {
    state = state.copyWith(tasks: tasks);
  }

  void setActiveTask(Task task) {
    state = state.copyWith(activeTask: task);
  }

  void setWorkTime(Duration workTime) {
    state = state.copyWith(
        activeTask: state.activeTask.copyWith(workDuration: workTime));
  }

  void playTimer() {
    state =
        state.copyWith(activeTask: state.activeTask.copyWith(isWorking: true));
  }

  void pauseTimer() {
    state =
        state.copyWith(activeTask: state.activeTask.copyWith(isWorking: false));
  }
}

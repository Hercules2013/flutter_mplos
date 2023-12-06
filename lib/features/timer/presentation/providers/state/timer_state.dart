import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';

/// User Status
///
/// 0 - offline
/// 1 - active
/// 2 - away
/// 3 - on break
/// 4 - on chat call

class TimerState {
  String errorMessage;
  List<Company> companies;
  String username, token;
  Company activeCompany;
  List<Task> tasks;
  Task? activeTask, lastTask;
  String startWorkTime;
  int userStatus;
  String timerStatus;

  Duration workTime;
  bool isLoading;
  String progress, progressColor;

  TimerState(
      {this.errorMessage = '',
      this.companies = const [],
      this.username = '',
      this.token = '',
      this.activeCompany = const Company(),
      this.tasks = const [],
      this.activeTask,
      this.progress = '',
      this.progressColor = '',
      this.lastTask,
      this.startWorkTime = '',
      this.userStatus = 0,
      this.timerStatus = '',
      this.workTime = Duration.zero,
      this.isLoading = false});

  TimerState.initial(
      {this.errorMessage = '',
      this.companies = const [],
      this.username = '',
      this.token = '',
      this.activeCompany = const Company(),
      this.tasks = const [],
      this.activeTask,
      this.progress = '',
      this.progressColor = '',
      this.lastTask,
      this.startWorkTime = '',
      this.userStatus = 0,
      this.timerStatus = '',
      this.workTime = Duration.zero,
      this.isLoading = false});

  TimerState copyWith(
      {String? errorMessage,
      List<Company>? companies,
      String? username,
      String? token,
      Company? activeCompany,
      List<Task>? tasks,
      Task? activeTask,
      String? progress,
      String? progressColor,
      Task? lastTask,
      String? startWorkTime,
      int? userStatus,
      String? timerStatus,
      Duration? workTime,
      bool? isLoading}) {
    return TimerState(
        errorMessage: errorMessage ?? this.errorMessage,
        companies: companies ?? this.companies,
        username: username ?? this.username,
        token: token ?? this.token,
        activeCompany: activeCompany ?? this.activeCompany,
        tasks: tasks ?? this.tasks,
        activeTask: activeTask ?? this.activeTask,
        progress: progress ?? this.progress,
        progressColor: progressColor ?? this.progressColor,
        lastTask: lastTask ?? this.lastTask,
        startWorkTime: startWorkTime ?? this.startWorkTime,
        userStatus: userStatus ?? this.userStatus,
        timerStatus: timerStatus ?? this.timerStatus,
        workTime: workTime ?? this.workTime,
        isLoading: isLoading ?? this.isLoading);
  }
}

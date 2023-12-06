import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mplos_chat/features/timer/domain/repositories/timer_repository.dart';
import 'package:mplos_chat/features/timer/presentation/providers/state/timer_state.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/domain/models/timer/task_model.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  final TimerRepository timerRepository;

  TimerNotifier({required this.timerRepository}) : super(TimerState.initial());

  Future<void> signIn(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final response =
        await timerRepository.signIn(username: username, password: password);
    state = state.copyWith(isLoading: false);
    response.fold((failure) {
      state = state.copyWith(
        errorMessage: 'Check your internet connection',
      );
    }, (data) {
      if (data.statusCode != 200) {
        state = state.copyWith(
          errorMessage: 'API error',
        );
      } else {
        final jsonData = jsonDecode(data.data.toString());

        if (jsonData['status'] == false) {
          state = state.copyWith(
            errorMessage: jsonData['message'],
          );
        } else {
          log('***** SignIn *****');
          log(jsonData.toString());
          state = state.copyWith(
              username: jsonData['name'],
              token: jsonData['token'],
              companies: (jsonData['company'] as List<dynamic>).map((data) {
                return Company(
                  id: int.parse(data['company_id'].toString()),
                  name: data['company_name'],
                  permission: data['permission'].toString(),
                  manager: data['manager'].toString(),
                  unreadMsgCount: int.parse(
                      data['unread_msg_count'].toString() == "null"
                          ? "0"
                          : data['unread_msg_count'].toString()),
                  userID: data['user']['id'],
                  userName: data['user']['name'],
                  userProfile: data['user']['profile'].toString(),
                  userColor: data['user']['color'],
                );
              }).toList());
        }
      }
    });
  }

  Future<String> getCredential() async {
    final credential = await timerRepository.getCredential();
    return credential.toString();
  }

  void saveCredential(String credential) {
    timerRepository.saveCredential(credential: credential);
  }

  Future<void> signOut() async {
    final response = await timerRepository.signOut(
        token: state.token, companyID: state.activeCompany.id);
    response.fold((failure) {}, (data) {});
  }

  void logOut() {
    state.activeTask = null;
    state = state.copyWith(
        token: '',
        activeCompany: null,
        companies: [],
        activeTask: null,
        tasks: []);
  }

  void setToken(String token) {
    state = state.copyWith(token: token);
  }

  void selectCompany(Company company) {
    state = state.copyWith(activeCompany: company);
  }

  Future<void> getCompanySetting() async {
    final response =
        await timerRepository.getCompanySetting(token: state.token);
    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());
      List<Company> companies = state.companies;
      if (jsonData['status'] == true) {
        for (var data in (jsonData['data'] as List<dynamic>)) {
          Company? selected = companies
              .where((el) => el.id == int.parse(data['company_id']))
              .firstOrNull;
          if (selected != null) {
            List<String> allowedApps =
                List<String>.from(data['settings']['software']);
            int index = companies.indexOf(selected);

            List<Software> allSofts = [];
            for (var soft
                in (data['settings']['all_software_data'] as List<dynamic>)) {
              SoftwareConcreteState softState =
                  SoftwareConcreteState.notRelated;
              if (soft['request_status'] == '0') {
                softState = SoftwareConcreteState.waiting;
              }
              if (soft['request_status'] == '1') {
                softState = SoftwareConcreteState.approved;
              }
              if (soft['request_status'] == '2') {
                softState = SoftwareConcreteState.rejected;
              }
              allSofts.add(
                  Software(title: soft['software_name'], state: softState));
            }

            companies[index] = companies[index]
                .copyWith(allowedApps: allowedApps, allSoftwares: allSofts);
          }
        }
      }
      state = state.copyWith(
          companies: companies, activeCompany: state.activeCompany.copyWith());
    });
  }

  void setCompanies(List<Company> companies) {
    state = state.copyWith(companies: companies);
  }

  Future<void> getMissions() async {
    state = state.copyWith(isLoading: true);

    final response = await timerRepository.getMissions(
        token: state.token, companyID: state.activeCompany.id);
    state = state.copyWith(isLoading: false);
    response.fold((failure) {
      state = state.copyWith(
        errorMessage: 'Check your internet connection',
      );
    }, (data) {
      final jsonData = jsonDecode(data.data.toString());

      if (jsonData['status'] == false) {
        state = state.copyWith(
          errorMessage: jsonData['message'],
        );
      } else {
        List<Task> tasks = (jsonData['missions'] as List<dynamic>).map((data) {
          return Task(
              id: int.parse(data['id']),
              name: data['name'],
              status: data['status'],
              link: data['link'],
              description: data['description'],
              workDuration: str2dur(data['working_time']));
        }).toList();
        state = state.copyWith(tasks: tasks);
      }
    });
  }

  Future<void> getMissionStatus(int taskID) async {
    final response = await timerRepository.getMissionStatus(
        companyID: state.activeCompany.id,
        token: state.token,
        missionID: taskID);
    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());
      if (jsonData['status'] == false) {
      } else {
        List<TaskStatus> allStatus =
            (jsonData['data'] as List<dynamic>).map((data) {
          return TaskStatus(
            id: int.parse(data['id']),
            status: data['status'],
            color: data['color'],
          );
        }).toList();

        if (state.activeTask != null && state.activeTask!.id == taskID) {
          state = state.copyWith(
              activeTask: state.activeTask!.copyWith(allStatus: allStatus));
        }
        state = state.copyWith(
            tasks: state.tasks
                .map((task) => task.id != taskID
                    ? task
                    : task.copyWith(allStatus: allStatus))
                .toList());
      }
    });
  }

  Future<void> changeMissionStatus(int status) async {
    // https://mplos.com/api.php?api=mission_status&token=N7HPYP977D4SERTASDFG&company_id=1&mission_id=2198&status=343
    final response = await timerRepository.changeMissionStatus(
        token: state.token,
        companyID: state.activeCompany.id,
        missionID: state.activeTask!.id,
        status: status);
    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());
      if (jsonData['status'] == true && state.activeTask != null) {
        state = state.copyWith(
            activeTask:
                state.activeTask!.copyWith(status: jsonData['mission_status']));
      }
    });
  }

  void setTasks(List<Task> tasks) {
    state = state.copyWith(tasks: tasks);
  }

  void setActiveTask(Task? task) {
    state.activeTask = task;
    state = state.copyWith(activeTask: task);
  }

  Future<void> startDailyWork(int taskID) async {
    final response = await timerRepository.startDailyWork(
        companyID: state.activeCompany.id,
        token: state.token,
        missionID: taskID);
    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());
      if (jsonData['status'] == false) {
        state = state.copyWith(
          errorMessage: jsonData['message'],
        );
      } else {
        log(data.data.toString());
        state = state.copyWith(
            workTime: Duration(
                hours: int.parse(jsonData['user_hours']),
                minutes: int.parse(jsonData['user_minutes']),
                seconds: int.parse(jsonData['user_seconds'])),
            activeTask: jsonData['mission_id'] != null
                ? state.tasks
                    .where(
                        (task) => task.id == int.parse(jsonData['mission_id']))
                    .first
                    .copyWith(isWorking: jsonData['timer_status'] == 'active')
                : null,
            progress: jsonData['mission_progress'],
            progressColor: jsonData['mission_progressbar_color'],
            startWorkTime: jsonData['day_start_time'],
            userStatus: int.parse(jsonData['user_status']),
            timerStatus: jsonData['timer_status'],
            lastTask: jsonData['today_last_task'] == ''
                ? null
                : Task(
                    id: int.parse(jsonData['today_last_task']['id']),
                    name: jsonData['today_last_task']['name'],
                    link: jsonData['today_last_task']['mission_url']));
      }
    });
  }

  Future<void> endDay() async {
    final response = await timerRepository.endWork(
        token: state.token, companyID: state.activeCompany.id);
    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());

      if (jsonData['status'] == false) {
        state = state.copyWith(
          errorMessage: jsonData['message'],
        );
      } else {
        state = state.copyWith(userStatus: 0, lastTask: state.activeTask);
      }
    });
  }

  Future<void> sendReport() async {
    List<String> selectUsers = [];
    if (state.activeCompany.manager == 'null') {
      selectUsers.add(state.activeCompany.userID);
    } else {
      selectUsers.add(state.activeCompany.manager);
    }
    final respnose = await timerRepository.sendReport(
        token: state.token,
        companyID: state.activeCompany.id,
        selectUsers: selectUsers);
    respnose.fold((failure) {}, (data) {
      log(data.data.toString());
    });
  }

  Future<void> pauseResumeWork(String actionType) async {
    // https://mplos.com/api.php?api=daily_work&action=resume&token=<TOKEN>&company_id=<COMPANY>
    final response = await timerRepository.pauseResumeWork(
        actionType: actionType,
        token: state.token,
        companyID: state.activeCompany.id);
    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data.toString());
      state = state.copyWith(userStatus: actionType == 'resume' ? 1 : 3);
      if (state.activeTask != null) {
        state = state.copyWith(
            activeTask:
                state.activeTask!.copyWith(isWorking: actionType == 'resume'));
      }
    });
  }

  void setStartWorkTime(String startWorkTime) {
    state = state.copyWith(startWorkTime: startWorkTime);
  }

  void setWorkTime(Duration workTime) {
    state = state.copyWith(workTime: workTime);
    // if (state.activeTask != null) {
    //   state = state.copyWith(
    //       activeTask: state.activeTask!.copyWith(workDuration: workTime),
    //       tasks: state.tasks
    //           .map((task) => task.id == state.activeTask!.id
    //               ? task.copyWith(workDuration: workTime)
    //               : task)
    //           .toList());
    // }
  }

  void increaseTaskTime() {
    if (state.activeTask == null) {
      state = state.copyWith(
        workTime: state.workTime + const Duration(seconds: 1),
      );
    } else {
      state = state.copyWith(
          workTime: state.workTime + const Duration(seconds: 1),
          activeTask: state.activeTask!.copyWith(
              workDuration:
                  state.activeTask!.workDuration + const Duration(seconds: 1)),
          tasks: state.tasks
              .map((task) => task.id == state.activeTask!.id
                  ? task.copyWith(
                      workDuration:
                          task.workDuration + const Duration(seconds: 1))
                  : task)
              .toList());
    }
  }

  void setLastTask(Task lastTask) {
    state = state.copyWith(lastTask: lastTask);
  }

  void setUserStatus(int status) {
    state = state.copyWith(userStatus: status);
  }

  void setTimerStatus(String status) {
    state = state.copyWith(timerStatus: status);
  }

  /// Related to Java App (Monitoring)
  Future<String> sendScreenshot(
      String filePath, int duration, String time) async {
    List<String> chunkPaths = filePath.split(r'\');
    final response = await timerRepository.sendScreenshot(
        token: state.token,
        companyID: state.activeCompany.id,
        path: filePath,
        appName: chunkPaths[chunkPaths.length - 2],
        time: time,
        duration: duration);
    String? returnMessage = '';
    response.fold((failure) {
      returnMessage = failure.message;
    }, (data) {
      final jsonData = jsonDecode(data.data.toString());
      returnMessage = jsonData['message'];
    });
    return returnMessage!;
  }

  Future<void> sendLog(String logData) async {
    DateTime today = DateTime.now();
    String date = "${today.year}-${today.month}-${today.day}";
    final response = await timerRepository.sendLog(
        token: state.token,
        companyID: state.activeCompany.id,
        date: date,
        logData: logData);
    response.fold((failure) {}, (data) {
      log('sent log');
      log(data.toString());
    });
  }

  void setActiveProgress(String progress, String progressColor) {
    state = state.copyWith(progress: progress, progressColor: progressColor);
  }

  Duration str2dur(String time) {
    List<String> arr = time.split(':');
    return Duration(
        hours: int.parse(arr[0]),
        minutes: int.parse(arr[1]),
        seconds: int.parse(arr[2]));
  }
}

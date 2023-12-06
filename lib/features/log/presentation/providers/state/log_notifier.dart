import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/log/domain/repositories/log_repository.dart';
import 'package:mplos_chat/features/log/presentation/providers/state/log_state.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';

class LogNotifier extends StateNotifier<LogState> {
  final LogRepository logRepository;

  LogNotifier({required this.logRepository}) : super(LogState());

  void setFilterOption(SoftwareConcreteState softwareStatus) {
    state = state.copyWith(filter: softwareStatus);
  }

  void setActivity(List<Software> softwares, DateTime dateTime) async {
    List<Software> processed = [];

    for (var soft in softwares) {
      List<Software> dup =
          processed.where((element) => element.title == soft.title).toList();
      if (dup.isEmpty) {
        processed.add(soft);
      } else {
        // int index = processed.indexOf(dup.first);
        // processed[index] = processed[index].copyWith(usage: soft.usage);
      }
    }

    final response = await logRepository.getActivity(dateTime: dateTime);

    List<dynamic> parsedData = [];
    List<Software> saved = [];
    if (response.toString() == 'null') {
      parsedData = [];
      saved = [];
    } else {
      parsedData = jsonDecode(response as String);

      saved = parsedData
          .map((json) => Software.fromJson(json))
          .cast<Software>()
          .toList();
    }

    for (var savedSoftware in saved) {
      List<Software> doubleList = processed
          .where((liveSoftware) => liveSoftware.title == savedSoftware.title)
          .toList();

      if (doubleList.isNotEmpty) {
        int index = processed.indexOf(doubleList.first);
        SoftwareConcreteState processedState = savedSoftware.state;
        if (savedSoftware.state == SoftwareConcreteState.notRelated ||
            processed[index].state != SoftwareConcreteState.notRelated) {
          processedState = processed[index].state;
        }

        processed[index] = processed[index].copyWith(state: processedState);
      } else {
        processed.add(savedSoftware);
      }
    }

    state = state.copyWith(softwares: processed);
    saveActivity(processed, DateTime.now());
  }

  void getActivty(DateTime dateTime) async {
    final response = await logRepository.getActivity(dateTime: dateTime);

    if (response.toString().compareTo("null") != 0) {
      List<dynamic> parsedData = jsonDecode(response as String);
      List<Software> saved = parsedData
          .map((json) => Software.fromJson(json))
          .cast<Software>()
          .toList();
      state = state.copyWith(softwares: saved);
    } else {
      state = state.copyWith(softwares: []);
    }
  }

  void saveActivity(List<Software> activities, DateTime dateTime) {
    logRepository.setActivity(softwares: activities, dateTime: dateTime);
  }

  void requestProgram(String program) async {
    final response = await logRepository.requestProgram(program);

    response.fold((failure) {}, (data) {
      final jsonData = jsonDecode(data.data);
      log(jsonData.toString());
      if (jsonData['status'] == true) {
        state = state.copyWith(
            softwares: state.softwares
                .map((e) => e.title == program
                    ? e.copyWith(state: SoftwareConcreteState.waiting)
                    : e)
                .toList());
      }
    });
  }

  void updateActivity(String name, String option) async {
    List<Software> softwares = state.softwares;
    if (option == 'accept') {
      softwares = softwares
          .map((el) => el.title.contains(name)
              ? el.copyWith(state: SoftwareConcreteState.approved)
              : el)
          .toList();
    }
    if (option == 'reject') {
      softwares = softwares
          .map((el) => el.title.contains(name)
              ? el.copyWith(state: SoftwareConcreteState.rejected)
              : el)
          .toList();
    }
    state = state.copyWith(softwares: softwares);
    saveActivity(softwares, DateTime.now());
  }
}

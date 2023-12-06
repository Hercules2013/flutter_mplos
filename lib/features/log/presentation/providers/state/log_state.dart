import 'package:mplos_chat/shared/domain/models/log/software_model.dart';

class LogState {
  final List<Software> softwares;
  final SoftwareConcreteState filter;

  LogState(
      {this.softwares = const [], this.filter = SoftwareConcreteState.all});

  LogState copyWith(
      {List<Software>? softwares, SoftwareConcreteState? filter}) {
    return LogState(
        softwares: softwares ?? this.softwares, filter: filter ?? this.filter);
  }
}

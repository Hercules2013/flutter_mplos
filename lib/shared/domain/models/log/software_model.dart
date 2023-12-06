import 'package:equatable/equatable.dart';

enum SoftwareConcreteState { all, notRelated, approved, rejected, waiting }

SoftwareConcreteState str2enum(String str) {
  if (str.endsWith('notRelated')) return SoftwareConcreteState.notRelated;
  if (str.endsWith('approved')) return SoftwareConcreteState.approved;
  if (str.endsWith('rejected')) return SoftwareConcreteState.rejected;
  if (str.endsWith('waiting')) return SoftwareConcreteState.waiting;
  return SoftwareConcreteState.all;
}

class Software extends Equatable {
  final String path, icon, title;
  final String startTime;
  final Duration usage;
  final SoftwareConcreteState state;

  const Software(
      {this.path = '',
      this.icon = '',
      this.title = '',
      this.startTime = '',
      this.usage = Duration.zero,
      this.state = SoftwareConcreteState.notRelated});

  @override
  List<Object?> get props => [path, icon, title, startTime, usage, state];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      'icon': icon,
      'title': title,
      'startTime': startTime,
      'usage': usage.inSeconds,
      'state': state.name,
    };
  }

  factory Software.fromJson(Map<String, dynamic> map) => Software(
      path: map['path'] ?? '',
      icon: map['icon'] ?? '',
      title: map['title'] ?? '',
      startTime: map['startTime'] ?? '',
      usage: Duration(seconds: map['usage']),
      state: str2enum(map['state']));

  Software copyWith(
      {String? path,
      String? icon,
      String? title,
      String? startTime,
      Duration? usage,
      SoftwareConcreteState? state}) {
    return Software(
      path: path ?? this.path,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      usage: usage ?? this.usage,
      state: state ?? this.state,
    );
  }
}

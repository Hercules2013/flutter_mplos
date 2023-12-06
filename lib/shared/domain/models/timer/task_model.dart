import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String name;
  final String status;
  final String link, description;
  final Duration workDuration;
  final bool isWorking;
  final List<TaskStatus> allStatus;

  final String estimation;

  const Task(
      {this.id = 0,
      this.name = "",
      this.status = "",
      this.link = "",
      this.description = "",
      this.workDuration = Duration.zero,
      this.isWorking = false,
      this.estimation = "",
      this.allStatus = const []});

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        link,
        description,
        workDuration,
        isWorking,
        estimation,
        allStatus
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'status': status,
      'link': link,
      'description': description,
      'workDuration': workDuration.toString(),
      'isWorking': isWorking,
      'estimation': estimation,
      'allStatus': allStatus.map((status) => status.toJson()).toList()
    };
  }

  factory Task.fromJson(Map<String, dynamic> map) => Task(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      link: map['link'] ?? '',
      description: map['description'] ?? '',
      workDuration: map['description'] != null
          ? formatDuration(map['workDuration'])
          : Duration.zero,
      isWorking: map['isWorking'] ?? false,
      estimation: map['estimation'] ?? "",
      allStatus: map['allStatus'] != null
          ? (map['allStatus'] as List<dynamic>)
              .map((el) => TaskStatus.fromJson(el))
              .toList()
          : []);

  Task copyWith(
      {int? id,
      String? name,
      String? status,
      String? link,
      String? description,
      Duration? workDuration,
      bool? isWorking,
      String? estimation,
      List<TaskStatus>? allStatus}) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      link: link ?? this.link,
      description: description ?? this.description,
      workDuration: workDuration ?? this.workDuration,
      isWorking: isWorking ?? this.isWorking,
      estimation: estimation ?? this.estimation,
      allStatus: allStatus ?? this.allStatus,
    );
  }

  @override
  bool operator ==(Object other) => other is Task && other.id == id;
}

Duration formatDuration(String duration) {
  List<String> parts = duration.split('.').first.split(':');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int seconds = int.parse(parts[2]);
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

class TaskStatus extends Equatable {
  final int id;
  final String status;
  final String color;

  const TaskStatus({this.id = 0, this.status = '', this.color = ''});

  @override
  List<Object?> get props => [id, status, color];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'status': status, 'color': color};
  }

  factory TaskStatus.fromJson(Map<String, dynamic> map) => TaskStatus(
      id: map['id'] ?? 0,
      status: map['status'] ?? '',
      color: map['color'] ?? '');

  TaskStatus copyWith({int? id, String? status, String? color}) {
    return TaskStatus(
        id: id ?? this.id,
        status: status ?? this.status,
        color: color ?? this.color);
  }
}

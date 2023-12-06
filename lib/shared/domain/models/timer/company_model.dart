import 'package:equatable/equatable.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';

class Company extends Equatable {
  final int id;
  final String name;
  final String permission;
  final String manager;
  final int unreadMsgCount;
  final String userID, userName, userProfile, userColor;
  final List<String> allowedApps;
  final List<Software> allSoftwares;

  const Company(
      {this.id = 0,
      this.name = "",
      this.permission = "",
      this.manager = "",
      this.unreadMsgCount = 0,
      this.userID = '',
      this.userName = '',
      this.userProfile = '',
      this.userColor = '',
      this.allowedApps = const [],
      this.allSoftwares = const []});

  @override
  List<Object?> get props => [
        id,
        name,
        permission,
        manager,
        unreadMsgCount,
        userID,
        userName,
        userProfile,
        userColor,
        allowedApps,
        allSoftwares
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'permission': permission,
      'manager': manager,
      'unreadMsgCount': unreadMsgCount,
      'userID': userID,
      'userName': userName,
      'userProfile': userProfile,
      'userColor': userColor,
      'allowedApps': allowedApps,
      'allSoftwares': allSoftwares.map((soft) => soft.toJson()).toList()
    };
  }

  factory Company.fromJson(Map<String, dynamic> map) => Company(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      permission: map['permission'] ?? '',
      manager: map['manager'] ?? '',
      unreadMsgCount: map['unreadMsgCount'] ?? 0,
      userID: map['userID'] ?? '',
      userName: map['userName'] ?? '',
      userProfile: map['userProfile'] ?? '',
      userColor: map['userColor'] ?? '',
      allowedApps: List<String>.from(map['allowedApps'] ?? []),
      allSoftwares: (map['allSoftwares'] as List<dynamic>)
          .map((el) => Software.fromJson(el))
          .toList());

  Company copyWith(
      {int? id,
      String? name,
      String? permission,
      String? manager,
      int? unreadMsgCount,
      String? userID,
      String? userName,
      String? userProfile,
      String? userColor,
      List<String>? allowedApps,
      List<Software>? allSoftwares}) {
    return Company(
        id: id ?? this.id,
        name: name ?? this.name,
        permission: permission ?? this.permission,
        manager: manager ?? this.manager,
        unreadMsgCount: unreadMsgCount ?? this.unreadMsgCount,
        userID: userID ?? this.userID,
        userName: userName ?? this.userName,
        userProfile: userProfile ?? this.userProfile,
        userColor: userColor ?? this.userColor,
        allowedApps: allowedApps ?? this.allowedApps,
        allSoftwares: allSoftwares ?? this.allSoftwares);
  }

  @override
  bool operator ==(Object other) => other is Company && other.id == id;
}

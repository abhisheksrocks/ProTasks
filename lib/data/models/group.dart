import 'package:flutter/foundation.dart';
import 'package:sembast/timestamp.dart';

import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/exceptions/group_exception.dart';

class Group {
  String id;
  String parentGroupId;
  String name;
  List<String> members;
  List<String> admins;
  DateTime createdOn;
  DateTime updatedOn;
  bool isSynced;

  Group({
    required this.id,
    required this.parentGroupId,
    required this.name,
    required this.members,
    required this.admins,
    required this.createdOn,
    required this.isSynced,
    required this.updatedOn,
  }) {
    if (parentGroupId == Strings.noGroupID) {
      admins.forEach((admin) {
        if (!members.contains(admin)) {
          throw GroupException(
            "Admin: $admin, isn't part of [Members], add it to [Members] also",
          );
        }
      });
    }
  }

  @override
  String toString() {
    return 'Group(id: $id, parentGroupId: $parentGroupId, name: $name, members: $members, admins: $admins, createdOn: $createdOn, updatedOn: $updatedOn, isSynced: $isSynced)';
  }

  Map<String, dynamic> toMapForDatabase() {
    assert(admins.every((_admin) {
      if (members.contains(_admin)) {
        return true;
      }
      return false;
    }));

    return {
      'id': id,
      'parentGroupId': parentGroupId,
      'name': name,
      'members': members,
      'admins': admins,
      'createdOn': Timestamp.fromDateTime(createdOn.toUtc()),
      'updatedOn': Timestamp.fromDateTime(updatedOn.toUtc()),
      'isSynced': isSynced,
    };
  }

  static Group fromMapFromDatabase(Map<String, dynamic> map) {
    assert(map['admins'].every((_admin) {
      if (map['members'].contains(_admin)) {
        return true;
      }
      return false;
    }));

    return Group(
      id: map['id'],
      parentGroupId: map['parentGroupId'] ?? Strings.noGroupID,
      name: map['name'],
      members: List<String>.from(map['members']),
      admins: List<String>.from(map['admins']),
      createdOn: (map['createdOn'] as Timestamp).toDateTime(),
      updatedOn: (map['updatedOn'] as Timestamp).toDateTime(),
      isSynced: map['isSynced'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Group &&
        other.id == id &&
        other.parentGroupId == parentGroupId &&
        other.name == name &&
        listEquals(other.members, members) &&
        // other.members.length == members.length &&
        listEquals(other.admins, admins) &&
        // other.admins.length == admins.length &&
        other.createdOn == createdOn &&
        other.updatedOn == updatedOn &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        parentGroupId.hashCode ^
        name.hashCode ^
        members.hashCode ^
        admins.hashCode ^
        createdOn.hashCode ^
        updatedOn.hashCode ^
        isSynced.hashCode;
  }

  Group copyWith({
    String? id,
    String? parentGroupId,
    String? name,
    List<String>? members,
    List<String>? admins,
    DateTime? createdOn,
    DateTime? updatedOn,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Group(
      id: id ?? this.id,
      parentGroupId: parentGroupId ?? this.parentGroupId,
      name: name ?? this.name,
      members: members ?? this.members,
      admins: admins ?? this.admins,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

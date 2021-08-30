import 'package:sembast/timestamp.dart';

class Person {
  String? name;
  String uid;
  String? email;
  DateTime updatedOn;
  bool isSynced;
  Person({
    this.name,
    required this.uid,
    this.email,
    required this.updatedOn,
    required this.isSynced,
  });

  Map<String, dynamic> toMapForDatabase() {
    return {
      'name': name,
      'uid': uid,
      'email': email,
      'updatedOn': Timestamp.fromDateTime(updatedOn.toUtc()),
      'isSynced': isSynced,
    };
  }

  static Person fromMapOfDatabase(Map<String, dynamic> map) {
    return Person(
      name: map['name'],
      uid: map['uid'],
      email: map['email'],
      updatedOn: (map['updatedOn'] as Timestamp).toDateTime(),
      isSynced: map['isSynced'],
    );
  }

  @override
  String toString() {
    return 'Person(name: $name, uid: $uid, email: $email, updatedOn: $updatedOn, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Person &&
        other.name == name &&
        other.uid == uid &&
        other.email == email &&
        other.updatedOn == updatedOn &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        uid.hashCode ^
        email.hashCode ^
        updatedOn.hashCode ^
        isSynced.hashCode;
  }

  Person copyWith({
    String? name,
    String? uid,
    String? email,
    DateTime? updatedOn,
    bool? isSynced,
  }) {
    return Person(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      updatedOn: updatedOn ?? this.updatedOn,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

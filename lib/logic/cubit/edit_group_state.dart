part of 'edit_group_cubit.dart';

@immutable
abstract class EditGroupState {}

class EditGroupLoading extends EditGroupState {}

class EditGroupLoaded extends EditGroupState {
  final Group groupToEdit;
  final Group updatedGroup;
  EditGroupLoaded({
    required this.groupToEdit,
    required this.updatedGroup,
  });

  bool get hasChanged {
    Group newgroupToEdit =
        Group.fromMapFromDatabase(groupToEdit.toMapForDatabase());
    Group newUpdatedGroup =
        Group.fromMapFromDatabase(updatedGroup.toMapForDatabase());
    newgroupToEdit..members.sort()..admins.sort();
    newUpdatedGroup..members.sort()..admins.sort();
    // print("Has changed called");
    // print(
    //     "groupToEdit.name: ${newgroupToEdit.name},\nupdatedGroup.name: ${newUpdatedGroup.name}\n");
    // print(
    //     "groupToEdit.members: ${newgroupToEdit.members},\nupdatedGroup.members: ${newUpdatedGroup.members}\n");
    // print(
    //     "groupToEdit.admins: ${newgroupToEdit.admins},\nupdatedGroup.admins: ${newUpdatedGroup.admins}\n");
    return newgroupToEdit != newUpdatedGroup;
    // groupToEdit..members.sort();
    // updatedGroup..members.sort();
    // groupToEdit..admins.sort();
    // updatedGroup..admins.sort();

    // return groupToEdit != updatedGroup;
  }

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;

  //   return other is EditGroupLoaded &&
  //       other.groupToEdit == groupToEdit &&
  //       other.updatedGroup == updatedGroup;
  // }

  // @override
  // int get hashCode => groupToEdit.hashCode ^ updatedGroup.hashCode;
}

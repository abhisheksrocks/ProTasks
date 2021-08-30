import 'package:bloc/bloc.dart';
import 'package:protasks/data/models/group.dart';
import 'package:meta/meta.dart';

part 'current_parent_group_state.dart';

class CurrentParentGroupCubit extends Cubit<CurrentParentGroup> {
  CurrentParentGroupCubit()
      : super(CurrentParentGroup(
          currentParentGroup: null,
        ));

  void changeParentGroup(Group? newGroup) {
    emit(CurrentParentGroup(currentParentGroup: newGroup));
  }
}

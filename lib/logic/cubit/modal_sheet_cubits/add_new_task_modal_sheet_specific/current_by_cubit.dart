import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'current_by_state.dart';

class CurrentByCubit extends Cubit<CurrentBy> {
  CurrentByCubit({
    bool? defaultIsBy,
  }) : super(CurrentBy(isBy: defaultIsBy ?? false));

  changeIsBy() {
    emit(CurrentBy(isBy: !state.isBy));
  }
}

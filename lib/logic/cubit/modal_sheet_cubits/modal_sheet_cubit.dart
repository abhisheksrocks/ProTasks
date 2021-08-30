import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'modal_sheet_state.dart';

class ModalSheetCubit extends Cubit<ModalSheetState> {
  ModalSheetCubit() : super(ModalSheetState(isExpanded: false));

  void changeExpanded() {
    emit(ModalSheetState(isExpanded: !state.isExpanded));
  }
}

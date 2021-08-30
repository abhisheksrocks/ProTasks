import 'package:bloc/bloc.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:meta/meta.dart';

part 'button_states_state.dart';

class ButtonStatesCubit extends Cubit<ButtonState> {
  final CurrentButtonState initialButtonState;
  ButtonStatesCubit({
    required this.initialButtonState,
  }) : super(ButtonState(
          currentButtonState: initialButtonState,
        ));

  void changeState({required CurrentButtonState newState}) {
    emit(ButtonState(
      currentButtonState: newState,
    ));
  }
}

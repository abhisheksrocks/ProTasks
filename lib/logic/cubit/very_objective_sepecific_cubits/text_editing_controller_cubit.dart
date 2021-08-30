import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'text_editing_controller_state.dart';

/// Before using in [BlocBuilder] make sure to call [beginFetching] beforehand via initState or something
/// with TextEditingController passed as parameter
class TextEditingControllerCubit extends Cubit<TextEditingControllerState>
    with ChangeNotifier {
  TextEditingController? textEditingController;

  TextEditingControllerCubit(
      //   {
      //   this.textEditingController,
      // }
      )
      : super(TextEditingControllerState(
          textString: '',
        )) {
    // textEditingController.addListener(() {
    //   String textFieldText = textEditingController.text.trim();
    //   if (textFieldText.isNotEmpty) {
    //     if (state.textString.isEmpty) {
    //       emit(TextEditingControllerState(textString: textFieldText));
    //     }
    //   } else {
    //     emit(TextEditingControllerState(textString: textFieldText));
    //   }
    // });
  }

  void _performActions(bool newStateEveryCharacter) {
    // print("here 1");
    String textFieldText = textEditingController!.text.trim();
    if (newStateEveryCharacter) {
      // print("here");
      emit(TextEditingControllerState(textString: textFieldText));
    } else {
      // Update the state only if the textfield was initially empty or is empty
      if (textFieldText.isNotEmpty) {
        if (state.textString.isEmpty) {
          emit(TextEditingControllerState(textString: textFieldText));
        }
      } else {
        emit(TextEditingControllerState(textString: textFieldText));
      }
    }
    // if (textFieldText.isNotEmpty) {
    //   if (newStateEveryCharacter) {
    //     emit(TextEditingControllerState(textString: textFieldText));
    //   } else if (state.textString.isEmpty) {
    //     emit(TextEditingControllerState(textString: textFieldText));
    //   }
    // } else {
    //   emit(TextEditingControllerState(textString: textFieldText));
    // }
  }

  void beginFetching({
    required TextEditingController newTextEditingController,
    bool newStateEveryCharacter = false,
  }) {
    // if (newTextEditingController.hasListeners) {
    //   print("Removing listeners");
    //   newTextEditingController.removeListener(() {});
    // }
    textEditingController = newTextEditingController;
    if (textEditingController != null) {
      // testing only
      // if (newTextEditingController.hasListeners) {
      //   print("Removing listeners");
      //   newTextEditingController.removeListener(() {
      //     print("removed");
      //   });
      // }
      // till here

      // if (!newTextEditingController.hasListeners) {
      textEditingController!.addListener(() {
        _performActions(newStateEveryCharacter);
      });
      _performActions(newStateEveryCharacter);
      // } else {
      //   print("Listener already there");
      // }
    }
  }

  @override
  Future<void> close() {
    textEditingController?.removeListener(() {});
    textEditingController?.dispose();
    return super.close();
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:meta/meta.dart';

part 'keyboard_visibility_with_focus_node_state.dart';

class KeyboardVisibilityWithFocusNodeCubit
    extends Cubit<KeyboardVisibilityWithFocusNodeState> {
  final KeyboardVisibilityController _keyboardVisibilityController =
      KeyboardVisibilityController();
  StreamSubscription? _streamSubscription;
  final FocusNode _focusNode = FocusNode();
  bool isVisible = false;

  FocusNode get getFocusNode => _focusNode;

  KeyboardVisibilityWithFocusNodeCubit()
      : super(KeyboardVisibilityWithFocusNodeInitial()) {
    _streamSubscription =
        _keyboardVisibilityController.onChange.listen((visible) {
      print("isKeyboardVisible: $visible");
      isVisible = visible;
    });
  }

  void dismissKeyboard() {
    if (isVisible) {
      print("Dismissing Keyboard");
      _focusNode.unfocus();
    }
  }

  void showKeyboard() {
    if (!isVisible) {
      print("Showing Keyboard after unfocus");
      _focusNode.unfocus();
      Timer(Duration(), () => _focusNode.requestFocus());
    } else {
      print("Already showing keyboard");
      //   focusNode.requestFocus();
    }
  }

  @override
  Future<void> close() {
    print("Disposing KeyboardVisibilityWithFocusNodeCubit");
    dismissKeyboard();
    _streamSubscription?.cancel();
    _focusNode.dispose();
    return super.close();
  }
}

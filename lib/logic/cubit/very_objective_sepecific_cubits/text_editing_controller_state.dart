part of 'text_editing_controller_cubit.dart';

@immutable
class TextEditingControllerState {
  final String textString;
  TextEditingControllerState({
    required this.textString,
  });

  @override
  String toString() => 'TextEditingControllerState(textString: $textString)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TextEditingControllerState &&
        other.textString == textString;
  }

  @override
  int get hashCode => textString.hashCode;
}

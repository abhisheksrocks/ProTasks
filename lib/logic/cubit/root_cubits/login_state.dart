part of 'login_cubit.dart';

@immutable
class LoginState {
  final CurrentLoginState currentLoginState;
  // final String? anyEmailAssigned;
  LoginState({
    required this.currentLoginState,
    // this.anyEmailAssigned,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'loginState': loginState.toMap(),
      'currentLoginState': EnumToString.convertToString(currentLoginState),
      // 'anyEmailAssigned': anyEmailAssigned,
    };
  }

  factory LoginState.fromMap(Map<String, dynamic> map) {
    return LoginState(
      // loginState: LoginState.fromMap(map['loginState']),
      currentLoginState: EnumToString.fromString(
              CurrentLoginState.values, map['currentLoginState']) ??
          CurrentLoginState.loggedOut,
      // anyEmailAssigned: map['anyEmailAssigned'],
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginState.fromJson(String source) =>
      LoginState.fromMap(json.decode(source));

  @override
  String toString() => 'LoginState(currentLoginState: $currentLoginState)';
}

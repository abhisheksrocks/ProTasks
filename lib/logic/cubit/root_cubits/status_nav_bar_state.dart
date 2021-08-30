part of 'status_nav_bar_cubit.dart';

@immutable
class StatusNavBar {
  final ThemeMode themeMode;
  final bool allowChange;
  StatusNavBar({
    required this.themeMode,
    required this.allowChange,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StatusNavBar &&
        other.themeMode == themeMode &&
        other.allowChange == allowChange;
  }

  @override
  int get hashCode => themeMode.hashCode ^ allowChange.hashCode;

  @override
  String toString() =>
      'StatusNavBar(themeMode: $themeMode, allowChange: $allowChange)';

  Map<String, dynamic> toMap() {
    return {
      'themeMode': EnumToString.convertToString(themeMode),
      'allowChange': allowChange,
    };
  }

  factory StatusNavBar.fromMap(Map<String, dynamic> map) {
    return StatusNavBar(
      themeMode: EnumToString.fromString(ThemeMode.values, map['themeMode']) ??
          ThemeMode.system,
      allowChange: map['allowChange'],
    );
  }

  String toJson() => json.encode(toMap());

  factory StatusNavBar.fromJson(String source) =>
      StatusNavBar.fromMap(json.decode(source));
}

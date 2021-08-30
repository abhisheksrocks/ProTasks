part of 'premium_checker_cubit.dart';

class PremiumCheckerState {
  final CurrentPremiumState currentPremiumState;
  final DateTime premiumTill;
  PremiumCheckerState({
    required this.currentPremiumState,
    required this.premiumTill,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PremiumCheckerState &&
        other.currentPremiumState == currentPremiumState &&
        other.premiumTill.toUtc() == premiumTill.toUtc();
  }

  @override
  int get hashCode => currentPremiumState.hashCode ^ premiumTill.hashCode;

  @override
  String toString() =>
      'PremiumCheckerState(currentPremiumState: $currentPremiumState, premiumTill: $premiumTill)';

  Map<String, dynamic> toMap() {
    return {
      'currentPremiumState': EnumToString.convertToString(currentPremiumState),
      'premiumTill': premiumTill.toUtc().millisecondsSinceEpoch,
    };
  }

  factory PremiumCheckerState.fromMap(Map<String, dynamic> map) {
    return PremiumCheckerState(
      currentPremiumState: EnumToString.fromString(
              CurrentPremiumState.values, (map['currentPremiumState'])) ??
          CurrentPremiumState.pseudoProUser,
      premiumTill:
          DateTime.fromMillisecondsSinceEpoch(map['premiumTill']).toUtc(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PremiumCheckerState.fromJson(String source) =>
      PremiumCheckerState.fromMap(json.decode(source));
}

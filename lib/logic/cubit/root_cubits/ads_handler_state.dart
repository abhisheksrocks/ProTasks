part of 'ads_handler_cubit.dart';

@immutable
class AdsHandlerStats {
  final int adsNotShownBecausePro;
  final int adsShown;
  final int currentStep;
  AdsHandlerStats({
    required this.adsShown,
    required this.adsNotShownBecausePro,
    required this.currentStep,
  });

  @override
  String toString() =>
      'AdsHandlerStats(adsNotShownBecausePro: $adsNotShownBecausePro, adsShown: $adsShown, currentStep: $currentStep)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdsHandlerStats &&
        other.adsNotShownBecausePro == adsNotShownBecausePro &&
        other.adsShown == adsShown &&
        other.currentStep == currentStep;
  }

  @override
  int get hashCode =>
      adsNotShownBecausePro.hashCode ^ adsShown.hashCode ^ currentStep.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'adsNotShownBecausePro': adsNotShownBecausePro,
      'adsShown': adsShown,
      'currentStep': currentStep,
    };
  }

  factory AdsHandlerStats.fromMap(Map<String, dynamic> map) {
    return AdsHandlerStats(
      adsNotShownBecausePro: map['adsNotShownBecausePro'],
      adsShown: map['adsShown'],
      currentStep: map['currentStep'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AdsHandlerStats.fromJson(String source) =>
      AdsHandlerStats.fromMap(json.decode(source));
}

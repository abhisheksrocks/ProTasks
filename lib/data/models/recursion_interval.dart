import 'package:protasks/logic/extra_functions.dart';

/// It is primarily used in [recursionInterval] property of [Task] model.
class RecursionInterval {
  // int seconds; //! DO NOT USE THIS BECAUSE ULTIMATELY THIS WILL CAUSE A LOT OF READS AND WRITES
  final int
      minutes; //! DO NOT USE THIS BECAUSE ULTIMATELY THIS CAN CAUSE A LOT OF READS AND WRITES IF EXPLOITED, unless constrained
  final int hours;
  final int days;
  final int months;
  final int years;
  const RecursionInterval({
    this.minutes = 0,
    this.hours = 0,
    this.days = 0,
    this.months = 0,
    this.years = 0,
  })  : assert(
            minutes >= 0, 'RecursiveInterval.minutes must be zero or positive'),
        assert(hours >= 0, 'RecursiveInterval.hours must be positive or zero'),
        assert(days >= 0, 'RecursiveInterval.days must be positive or zero'),
        assert(
            months >= 0, 'RecursiveInterval.months must be positive or zero'),
        assert(years >= 0, 'RecursiveInterval.years must be positive or zero'),
        assert(
            (hours == 0 &&
                    days == 0 &&
                    months == 0 &&
                    years == 0 &&
                    (minutes >= 30 || minutes == 0)) ||
                (hours > 0 || days > 0 || months > 0 || years > 0),
            '[RecursionInterval] should be zero or more than 30 minutes atleast');

  // RecursiveTime operator +(RecursiveTime other) {
  //   return RecursiveTime(
  //     days: other.days + days,
  //     hours: other.hours + hours,
  //     months: other.months + months,
  //     years: other.years + years,
  //   );
  // }

  // Random jab at it
  // RecursionInterval operator *(int times) {
  //   return RecursionInterval(
  //     hours: hours * times,
  //     days: days * times,
  //     months: months * times,
  //     years: years * times,
  //   );
  // }

  DateTime operator +(DateTime other) {
    return DateTime(
      other.year + years,
      other.month + months,
      other.day + days,
      other.hour + hours,
      other.minute + minutes,
      other.second,
      other.millisecond,
      other.microsecond,
    );
  }

  static const RecursionInterval zero = RecursionInterval();

  static RecursionInterval fromMap(Map<String, dynamic> map) {
    assert(map['minutes'] >= 0,
        'RecursiveInterval.minutes must be zero or more than or equal to 30');
    assert(
        map['hours'] >= 0, 'RecursiveInterval.hours must be positive or zero');
    assert(map['days'] >= 0, 'RecursiveInterval.days must be positive or zero');
    assert(map['months'] >= 0,
        'RecursiveInterval.months must be positive or zero');
    assert(
        map['years'] >= 0, 'RecursiveInterval.years must be positive or zero');
    assert(
        (map['hours'] == 0 &&
                map['days'] == 0 &&
                map['months'] == 0 &&
                map['years'] == 0 &&
                (map['minutes'] >= 30 || map['minutes'] == 0)) ||
            (map['hours'] > 0 ||
                map['days'] > 0 ||
                map['months'] > 0 ||
                map['years'] > 0),
        '[RecursionInterval] should be zero or more than 30 minutes atleast');
// ? I'm not sure if we even need to check with '??' since we already are asserting few things
    return RecursionInterval(
      minutes: map['minutes'] ?? 0,
      hours: map['hours'] ?? 0,
      days: map['days'] ?? 0,
      months: map['months'] ?? 0,
      years: map['years'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RecursionInterval &&
        other.minutes == minutes &&
        other.hours == hours &&
        other.days == days &&
        other.months == months &&
        other.years == years;
  }

  @override
  int get hashCode {
    return minutes.hashCode ^
        hours.hashCode ^
        days.hashCode ^
        months.hashCode ^
        years.hashCode;
  }

  @override
  String toString() {
    return 'RecursiveInterval(minutes: $minutes, hours: $hours, days: $days, months: $months, years: $years)';
  }

  String get recursionIntervalToString {
    String stringToReturn = '';
    if (years != 0) {
      stringToReturn = "$years year";
    }
    if (months != 0) {
      stringToReturn =
          "${stringToReturn.isEmpty ? "${ExtraFunctions.stringToAppendWith(
              unitValue: months,
              unitString: "month",
            )}" : "$stringToReturn, ${ExtraFunctions.stringToAppendWith(
              unitValue: months,
              unitString: "month",
            )}"}";
    }
    if (days != 0) {
      stringToReturn =
          "${stringToReturn.isEmpty ? "${ExtraFunctions.stringToAppendWith(
              unitValue: days,
              unitString: "day",
            )}" : "$stringToReturn, ${ExtraFunctions.stringToAppendWith(
              unitValue: days,
              unitString: "day",
            )}"}";
    }
    if (hours != 0) {
      stringToReturn =
          "${stringToReturn.isEmpty ? "${ExtraFunctions.stringToAppendWith(
              unitValue: hours,
              unitString: "hour",
            )}" : "$stringToReturn, ${ExtraFunctions.stringToAppendWith(
              unitValue: hours,
              unitString: "hour",
            )}"}";
    }
    if (minutes != 0) {
      stringToReturn =
          "${stringToReturn.isEmpty ? "${ExtraFunctions.stringToAppendWith(
              unitValue: minutes,
              unitString: "minute",
            )}" : "$stringToReturn, ${ExtraFunctions.stringToAppendWith(
              unitValue: minutes,
              unitString: "minute",
            )}"}";
    }
    return stringToReturn;
  }

  /// This toMap() is also applicable for database
  Map<String, dynamic> toMap() {
    return {
      'minutes': minutes,
      'hours': hours,
      'days': days,
      'months': months,
      'years': years,
    };
  }
}

// extension RecursionIntervalExtensions on RecursionInterval {
//   static RecursionInterval get invalid => RecursionInterval();
// }

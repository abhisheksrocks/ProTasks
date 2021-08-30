

extension DateTimeExtensions on DateTime {
  static DateTime get invalid =>
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

extension StringExtensions on String {
  String get inCaps => this.length > 0
      ? '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}'
      : '';

  String get capitalize => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");

  bool get isValidEmail {
    // return RegExp(
    //         r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
    //     .hasMatch(this);
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
}

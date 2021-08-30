import 'package:flutter/widgets.dart';

class MyNavigator {
  // MyNavigator({required GlobalKey<NavigatorState> navigatorKey});

  static final MyNavigator _myNavigator = MyNavigator._internal();

  factory MyNavigator() {
    return _myNavigator;
  }

  MyNavigator._internal();

  static GlobalKey<NavigatorState>? _navigatorKey;

  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    if (_navigatorKey == null) {
      _navigatorKey = navigatorKey;
    }
  }

  static BuildContext? get context => _navigatorKey?.currentContext;
}

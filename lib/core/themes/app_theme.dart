import 'package:protasks/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class AppTheme {
  const AppTheme._();

  //Theming
  static Color lightBackgroundColor = const Color(0xFFFFFFFF);
  static Color lightPrimaryColor = const Color(0xFF5665FF);
  static Color lightAccentColor = const Color(0xFF5665FF);
  static Color lightDividerColor = const Color(0xFFDBDBDB);
  static Color lightTaskGroupColor = const Color(0xFF141414);

  static Color lightChatBackgroundColor = const Color(0xFFF2F2F2);
  static ButtonStyle lightTextButtonStyle = TextButton.styleFrom(
    backgroundColor: lightPrimaryColor.withOpacity(0.2),
    primary: lightPrimaryColor,
  );

  static TimePickerThemeData lightTimePickerThemeData = TimePickerThemeData(
    backgroundColor: lightBackgroundColor,
    dialBackgroundColor: Colors.black.withOpacity(0.1),
    dayPeriodBorderSide: BorderSide(
      color: Colors.black.withOpacity(0.5),
    ),
  );

  static Color darkBackgroundColor = const Color(0xFF202837);
  static Color darkPrimaryColor = const Color(0xFF293448);
  static Color darkAccentColor = const Color(0xFF5665FF);
  static Color darkDividerColor = const Color(0xFF32415D);
  static Color darkTaskGroupColor = const Color(0xFFDDDDDD);

  static Color darkChatBackgroundColor = const Color(0xFF000000);
  static ButtonStyle darkTextButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.2),
    primary: Colors.white,
  );

  static TimePickerThemeData darkTimePickerThemeData = TimePickerThemeData(
    backgroundColor: darkBackgroundColor,
  );

  static const Color taskAddOnColor = const Color(0xFF90949B);
  static const Color overdueColor = const Color(0xFFFF5252);
  static const Color highPriorityColor = const Color(0xFFAB47BC);
  static const Color mediumPriorityColor = const Color(0xFF40B45C);
  static const Color lowPriorityColor = const Color(0xFF777B84);

  static ButtonStyle errorTextButtonStyle = TextButton.styleFrom(
    backgroundColor: overdueColor,
    primary: Colors.white,
  );

  static ButtonStyle greenTextButtonStyle = TextButton.styleFrom(
    backgroundColor: mediumPriorityColor,
    primary: Colors.white,
  );

  static ButtonStyle alternateTextButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.2),
    primary: Colors.white,
  );

  static ButtonStyle myTextButtonStyle = TextButton.styleFrom(
    backgroundColor: AppTheme.darkAccentColor,
    primary: Colors.white,
  );

  //Marker for StatusNavBarCubit
  static Brightness brightnessSetByCubit = Brightness.light;

  //Themes
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimaryColor,
    accentColor: lightAccentColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    backgroundColor: lightBackgroundColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    dividerColor: lightDividerColor,
    dividerTheme: DividerThemeData(
      thickness: 0.8,
    ),
    fontFamily: Strings.primaryFontFamily,
    timePickerTheme: lightTimePickerThemeData,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.black,
        backgroundColor: Colors.black.withOpacity(0.1),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.transparent,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    accentColor: darkAccentColor,
    // accentColor: darkDividerColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    backgroundColor: darkBackgroundColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    dividerColor: darkDividerColor,
    dividerTheme: DividerThemeData(
      thickness: 0.8,
    ),
    fontFamily: Strings.primaryFontFamily,
    timePickerTheme: darkTimePickerThemeData,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.1),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.black.withOpacity(0),
    ),
  );

  //Functions
  static Brightness get currentBrightness =>
      SchedulerBinding.instance!.window.platformBrightness;

  static void updateStatusAndNavigationBar({required ThemeMode themeMode}) {
    SystemChrome.setSystemUIOverlayStyle(new SystemUiOverlayStyle(
      // * Change status bar color based on Theme primary color
      statusBarColor: Colors.transparent,
      // statusBarColor:
      //     themeMode == ThemeMode.light ? lightPrimaryColor : darkPrimaryColor,

      // * Change status bar icon white(Brightness.dark) or black(Brighness.white)
      statusBarIconBrightness: Brightness.dark,
      // statusBarIconBrightness:
      //     themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,

      // * Change Navigation bar icon white(Brigtness.light) or black(Brightness.dark)
      // systemNavigationBarIconBrightness:
      //     themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      // systemNavigationBarIconBrightness:
      //     themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,

      // * Change navigation bar color
      systemNavigationBarColor:
          themeMode == ThemeMode.light ? lightPrimaryColor : darkPrimaryColor,
      // systemNavigationBarColor: themeMode == ThemeMode.light
      //     ? lightBackgroundColor
      //     : darkBackgroundColor,

      // ! statusBarBrightness doesn't work, so better use [MyDefaultSliverAppBar]
      // ! or update brightness property of Scaffold as per [brightnessSetByCubit]
      // statusBarBrightness:
      //     themeMode == ThemeMode.light ? Brightness.dark : Brightness.dark,

      // * Places a divider between Navigation bar and the app
      systemNavigationBarDividerColor: Colors.transparent,
      // systemNavigationBarDividerColor:
      //     themeMode == ThemeMode.light ? lightPrimaryColor : darkPrimaryColor,
    ));

    // * same as statusBarIconBrightness, used in [MyDefaultSliverAppBar]
    // brightnessSetByCubit = Brightness.dark;
    print("Successful");
  }
}

extension ThemeExtras on ThemeData {
  Color get taskGroupColor => this.brightness == Brightness.light
      ? AppTheme.darkTaskGroupColor
      : AppTheme.lightTaskGroupColor;
  Color get taskAddOnColor => AppTheme.taskAddOnColor;
  Color get overdueBannerColor => AppTheme.overdueColor;
  Color get highPriorityBannerColor => AppTheme.highPriorityColor;
  Color get mediumPriorityBannerColor => AppTheme.mediumPriorityColor;
  Color get lowPriorityBannerColor => AppTheme.lowPriorityColor;
  Color get secondaryTextColor =>
      this.brightness != Brightness.light ? Colors.black : Colors.white;
  Color get primaryTextColor =>
      this.brightness == Brightness.light ? Colors.black : Colors.white;
  ButtonStyle get errorTextButtonStyle => AppTheme.errorTextButtonStyle;
  ButtonStyle get greenTextButtonStyle => AppTheme.greenTextButtonStyle;
  ButtonStyle get alternateTextButtonStyle => AppTheme.alternateTextButtonStyle;
  Color get chatBackgroundColor => this.brightness != Brightness.light
      ? AppTheme.darkChatBackgroundColor
      : AppTheme.lightChatBackgroundColor;
  Color get chatTextFieldColor => this.brightness != Brightness.light
      ? Colors.black.withOpacity(0.25)
      : Colors.grey.withOpacity(0.25);
  // : AppTheme.lightPrimaryColor.withOpacity(0.05);
  ButtonStyle get textButtonThemeStyle => this.brightness != Brightness.light
      ? AppTheme.darkTextButtonStyle
      : AppTheme.lightTextButtonStyle;
  ButtonStyle get myTextButtonStyle => TextButton.styleFrom(
        backgroundColor: this.accentColor,
        primary: Colors.white,
      );
  // this.brightness == Brightness.light
  //     ? AppTheme.alternateTextButtonStyle
  //     : this.textButtonTheme.style!;
}

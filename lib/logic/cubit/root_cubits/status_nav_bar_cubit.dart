
import 'package:protasks/core/themes/app_theme.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

part 'status_nav_bar_state.dart';

class StatusNavBarCubit extends HydratedCubit<StatusNavBar> {
  StatusNavBarCubit()
      : super(StatusNavBar(
          themeMode: ThemeMode.system,
          allowChange: true,
        )) {
    // _setStatusAndNavigationBar(ThemeMode.system);
    updateStatusAndNavigationBar();
  }

  void updateStatusAndNavigationBar({
    Brightness? brightnessToSet,
    bool forceChange = false,
  }) {
    if (state.allowChange || forceChange) {
      Brightness _currentBrightness =
          brightnessToSet ?? AppTheme.currentBrightness;
      if (_currentBrightness == Brightness.light) {
        _setStatusAndNavigationBar(
          ThemeMode.light,
          brightnessToSet == null,
        );
      } else {
        _setStatusAndNavigationBar(
          ThemeMode.dark,
          brightnessToSet == null,
        );
      }
    }
  }

  void _setStatusAndNavigationBar(
    ThemeMode themeMode,
    bool allowChange,
  ) {
    print("$themeMode");
    AppTheme.updateStatusAndNavigationBar(
      themeMode: themeMode,
    );
    emit(StatusNavBar(
      themeMode: themeMode,
      allowChange: allowChange,
    ));
  }

  @override
  StatusNavBar? fromJson(Map<String, dynamic> json) {
    return StatusNavBar.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(StatusNavBar state) {
    return state.toMap();
  }
}

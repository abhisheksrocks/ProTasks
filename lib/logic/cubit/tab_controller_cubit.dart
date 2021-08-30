import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'tab_controller_state.dart';

class TabControllerCubit extends Cubit<TabControllerState> {
  final TabController tabController;
  TabControllerCubit({
    required this.tabController,
  }) : super(TabControllerState(tabController: tabController));

  void changeIndex(int newIndex) {
    tabController.animateTo(
      newIndex,
      curve: Curves.easeInOut,
    );
  }
}

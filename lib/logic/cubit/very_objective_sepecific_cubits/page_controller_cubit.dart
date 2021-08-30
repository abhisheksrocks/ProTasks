import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'page_controller_state.dart';

class PageControllerCubit extends Cubit<PageControllerState> {
  final PageController pageController;
  PageControllerCubit({
    required this.pageController,
  }) : super(PageControllerState(
          currentPage: 0,
        )) {
    initialize();
  }

  void nextPage() {
    pageController.nextPage(
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
    );
  }

  void previousPage() {
    pageController.previousPage(
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
    );
    // pageController.animateToPage(
    //   0,
    //   duration: Duration(milliseconds: 1000),
    //   curve: Curves.easeInOut,
    // );
  }

  void initialize() {
    pageController.addListener(() {
      // print("currentPage: ${pageController.page}");
      emit(PageControllerState(currentPage: pageController.page!));
    });
  }
}

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'pageview_animation_state.dart';

class PageviewAnimationCubit extends Cubit<PageviewAnimationState> {
  PageController? _pageController;
  int? _numberOfPages;
  PageviewAnimationCubit() : super(PageviewAnimationInitial());

  bool _whileFinished = false;

  void initializeController({
    required PageController newPageController,
    required int numberOfPages,
  }) async {
    _pageController = newPageController;
    _numberOfPages = numberOfPages;
    _whileFinished = false;
    doPageAnimation();
    emit(PageviewAnimationBegin());
  }

  void doPageAnimation() async {
    await Future.delayed(Duration(seconds: 5));
    while (state is PageviewAnimationBegin && !_whileFinished) {
      int nextPage = (_pageController!.page)!.toInt() + 1;
      if (nextPage == _numberOfPages!) {
        nextPage = 0;
      }
      _pageController!.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
      await Future.delayed(Duration(seconds: 5));
    }
    stopWhileFunction();
  }

  void changePausedState() async {
    if (state is PageviewAnimationPause) {
      // await Future.delayed(Duration(seconds: 2));
      emit(PageviewAnimationBegin());
      if (_whileFinished) {
        _whileFinished = false;
        doPageAnimation();
      }
    } else {
      emit(PageviewAnimationPause());
    }
  }

  void stopWhileFunction() {
    _whileFinished = true;
  }

  @override
  Future<void> close() {
    stopWhileFunction();
    print("PageviewAnimationCubit closed");
    return super.close();
  }
}

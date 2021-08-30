part of 'page_controller_cubit.dart';

@immutable
class PageControllerState {
  final double currentPage;
  PageControllerState({
    required this.currentPage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageControllerState && other.currentPage == currentPage;
  }

  @override
  int get hashCode => currentPage.hashCode;
}

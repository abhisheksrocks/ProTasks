import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'loading_state.dart';

class LoadingCubit extends Cubit<LoadingState> {
  LoadingCubit() : super(LoadingState(isLoading: false));

  void changeLoading({bool? isLoading}) {
    if (isLoading != null) {
      emit(LoadingState(isLoading: isLoading));
    } else {
      emit(LoadingState(isLoading: !state.isLoading));
    }
  }
}

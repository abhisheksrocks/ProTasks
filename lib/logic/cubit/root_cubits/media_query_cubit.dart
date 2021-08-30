import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'media_query_cubit_state.dart';

class MediaQueryCubit extends Cubit<MediaQueryCubitState> {
  MediaQueryCubit()
      : super(
          MediaQueryCubitState(
            padding: EdgeInsets.zero,
            size: Size.zero,
          ),
        );

  void updateValues({required EdgeInsets padding, required Size size}) {
    emit(MediaQueryCubitState(
      padding: padding,
      size: size,
    ));
  }
}

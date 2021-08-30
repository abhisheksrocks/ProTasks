import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/person.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'members_search_state.dart';

class MembersSearchCubit extends Cubit<MembersSearch> {
  MembersSearchCubit()
      : super(MembersSearch(
          usersToShow: [],
        )) {
    initialize();
  }

  Person? currentPerson;

  List<Person> usersToSearchFrom = [];
  StreamSubscription? _streamSubscription;

  void initialize() async {
    _streamSubscription = UsersDao()
        .getAllUsersStored()
        .asBroadcastStream()
        .listen((event) async {
      if (currentPerson == null) {
        currentPerson = await UsersDao().getCurrentUser();
      }
      event = event.toSet().toList();
      event.removeWhere((element) => element.uid == currentPerson!.uid);
      // event.remove(currentPerson);
      usersToSearchFrom = event;
      emit(MembersSearch(
        usersToShow: state.usersToShow,
        forceNewState: true,
      ));
    });
    emit(MembersSearch(usersToShow: usersToSearchFrom));
  }

  void searchWithQuery(String? searchQuery) {
    searchQuery = searchQuery?.trim();
    if (searchQuery == null || searchQuery.isEmpty) {
      emit(MembersSearch(usersToShow: usersToSearchFrom));
    } else {
      List<Person> usersToShow = [];
      RegExp _regExp = RegExp(
        "$searchQuery",
        caseSensitive: false,
      );
      usersToSearchFrom.forEach((user) {
        if (_regExp.hasMatch(user.name ?? '') ||
            _regExp.hasMatch(user.email ?? '')) {
          usersToShow.add(user);
        }
      });
      emit(MembersSearch(usersToShow: usersToShow));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}

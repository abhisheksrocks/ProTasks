

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:meta/meta.dart';
import 'package:protasks/logic/package_info_handler.dart';
import 'package:version/version.dart';

part 'version_checker_state.dart';

class VersionCheckerCubit extends Cubit<VersionCheckerState> {
  VersionCheckerCubit()
      : super(VersionCheckerState(
          needsUpdate: false,
        )) {
    configure();
  }

  CancelableOperation? _nextUpdateCancelableOperation;

  Future<void> fetchValuesAndPerformAction() async {
    await FirebaseRConfigHandler.fetchAndActivate();
    _nextUpdateCancelableOperation?.cancel();
    String appVersion = PackageInfoHandler.version;
    Version currentAppVersion = Version.parse(appVersion);
    Version leastRecommendedVersion =
        Version.parse(FirebaseRConfigHandler.leastRecommendedVersion);
    print("CurrentAppVersion: $currentAppVersion");
    print("androidRecommendedVersion: $leastRecommendedVersion");
    print("forcefree: ${FirebaseRConfigHandler.forceFree}");
    if (currentAppVersion < leastRecommendedVersion) {
      emit(VersionCheckerState(needsUpdate: true));
    } else {
      emit(VersionCheckerState(needsUpdate: false));
    }
    _nextUpdateCancelableOperation = CancelableOperation.fromFuture(
        Future.delayed(FirebaseRConfigHandler.minimumFetchTimeout));
    _nextUpdateCancelableOperation?.value.then((_) async {
      await fetchValuesAndPerformAction();
    });
  }

  void configure() async {
    fetchValuesAndPerformAction();
  }

  @override
  Future<void> close() {
    _nextUpdateCancelableOperation?.cancel();
    return super.close();
  }
}

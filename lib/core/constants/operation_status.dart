import 'package:protasks/core/constants/enums.dart';

class OperationStatus {
  final ReturnStatus returnStatus;
  final DatabaseInsertStatus databaseInsertStatus;
  OperationStatus({
    required this.returnStatus,
    required this.databaseInsertStatus,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OperationStatus &&
        other.returnStatus == returnStatus &&
        other.databaseInsertStatus == databaseInsertStatus;
  }

  @override
  int get hashCode => returnStatus.hashCode ^ databaseInsertStatus.hashCode;
}

import 'package:cloud_functions/cloud_functions.dart';

class FirebaseCFunctionHandler {
  static Future<bool> leaveFromGroup({required String groupId}) async {
    HttpsCallable leaveFromGroup =
        FirebaseFunctions.instance.httpsCallable('leaveFromGroup');

    Map<String, dynamic> dataToPass = {};
    dataToPass['groupId'] = groupId;
    try {
      final value = await leaveFromGroup(dataToPass);
      print("Returned Value: ${value.data}");
      if (value.data == null) {
        return false;
      }
      return true;
    } catch (exception) {
      print("leaveFromGroup exception: $exception");
      return false;
    }
  }
}

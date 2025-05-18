import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  static Future<String> getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    return userId ?? '';
  }
}

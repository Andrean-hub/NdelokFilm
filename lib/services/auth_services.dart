import 'package:shared_preferences/shared_preferences.dart';

// Fungsi untuk menyimpan token
Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

// Fungsi untuk mengambil token
Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

// Fungsi untuk menghapus token
Future<void> removeToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
}

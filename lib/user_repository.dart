import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class UserRepository {
  final String baseUrl = 'http://192.168.0.102:8080'; // Ganti dengan base URL backend kamu

  Future<void> addUser(User user, String uid) async {
    final url = Uri.parse('$baseUrl/users');


    final userMap = user.toMap();

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userMap),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menyimpan user ke backend: ${response.body}');
    }
  }
}

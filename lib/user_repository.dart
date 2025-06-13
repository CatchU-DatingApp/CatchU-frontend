import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class UserRepository {
  final String baseUrl = 'http://172.20.10.3:8080'; // Ganti dengan base URL backend kamu

  Future<void> addUser(User user, String uid) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .set(user.toMap());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class UserRepository {
  Future<void> addUser(User user) async {
    await FirebaseFirestore.instance.collection('Users').add(user.toMap());
  }
}
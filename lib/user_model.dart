import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String nomorTelepon;
  final String nama;
  final String email;
  final int umur;
  final String gender;
  final List<String> interest;
  final String kodeOtp;
  final List<double> location;
  // final String? photoUrl; // jika ada

  User({
    this.id,
    required this.nomorTelepon,
    required this.nama,
    required this.email,
    required this.umur,
    required this.gender,
    required this.interest,
    required this.kodeOtp,
    required this.location,
    // this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nomorTelepon': nomorTelepon,
      'nama': nama,
      'email': email,
      'umur': umur,
      'gender': gender,
      'interest': interest,
      'kodeOtp': kodeOtp,
      'location': location,
      // 'photoUrl': photoUrl,
    };
  }
}
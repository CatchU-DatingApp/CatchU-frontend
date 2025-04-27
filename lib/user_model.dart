import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String email;
  final String gender;
  final List<String> interest;
  final String kodeOtp;
  final List<double> location;
  final String nama;
  final String nomorTelepon;
  final int umur;

  const UserModel({
    this.id,
    required this.email,
    required this.gender,
    required this.interest,
    required this.kodeOtp,
    required this.location,
    required this.nama,
    required this.nomorTelepon,
    required this.umur,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "gender": gender,
      "interest": interest,
      "kode_otp": kodeOtp,
      "location": location,
      "nama": nama,
      "nomor_telepon": nomorTelepon,
      "umur": umur,
    };
  }
}
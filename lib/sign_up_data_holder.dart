import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

class SignUpDataHolder {
  String? phoneNumber;
  String? nama;
  String? email;
  int? umur;
  String? gender;
  List<String>? interest;
  String? photoUrl;
  List<double>? location;
  List<File>? photos;
  List<String>? photoUrls;
  PhoneAuthCredential? phoneAuthCredential;
  String? verificationId;

  SignUpDataHolder({
    this.phoneNumber,
    this.nama,
    this.email,
    this.umur,
    this.gender,
    this.interest,
    this.photoUrl,
    this.location,
    this.photos,
    this.phoneAuthCredential,
    this.verificationId,
  });
}

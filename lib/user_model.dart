class User {
  final String? id;
  final String nomorTelepon;
  final String nama;
  final String email;
  final int umur;
  final String gender;
  final List<String> interest;
  final bool verified;
  final List<double> location;
  final List<String> photos;

  User({
    this.id,
    required this.nomorTelepon,
    required this.nama,
    required this.email,
    required this.umur,
    required this.gender,
    required this.interest,
    required this.verified,
    required this.location,
    required this.photos,
  });

  Map<String, dynamic> toMap() {
    return {
      'nomorTelepon': nomorTelepon,
      'nama': nama,
      'email': email,
      'umur': umur,
      'gender': gender,
      'interest': interest,
      'verified': verified,
      'location': location,
      'photos': photos,
    };
  }
}

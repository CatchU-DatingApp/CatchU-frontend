import 'package:catchu/auth/sign_up/sign_up10_Rules.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:catchu/sign_up_data_holder.dart';
import 'package:catchu/user_model.dart' as app;
import 'package:catchu/user_repository.dart';
import 'package:catchu/services/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage9Location extends StatefulWidget {
  final SignUpDataHolder dataHolder;
  const SignUpPage9Location({Key? key, required this.dataHolder})
    : super(key: key);

  @override
  State<SignUpPage9Location> createState() => _SignUpPage9LocationState();
}

class _SignUpPage9LocationState extends State<SignUpPage9Location> {
  bool _isLoading = false;
  String? _errorMessage;
  Position? _position;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please enable location services';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Location permissions are denied';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location permissions are permanently denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = position;
        _isLoading = false;
        _errorMessage = null;
      });
      widget.dataHolder.location = [position.latitude, position.longitude];
      _showLocationDialog(position);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to get location: $e';
      });
    }
  }

  void _showLocationDialog(Position position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 300,
                    child: FlutterMap(
                      options: MapOptions(
                        center: LatLng(position.latitude, position.longitude),
                        zoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                position.latitude,
                                position.longitude,
                              ),
                              width: 80,
                              height: 80,
                              child: Icon(
                                Icons.location_pin,
                                color: Color(0xFFFF2E63),
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Is this where you are?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF2E63),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('Deny'),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _finishSignUp();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF2E63),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _finishSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appUser = app.User(
        id: null,
        nomorTelepon: widget.dataHolder.phoneNumber ?? '',
        nama: widget.dataHolder.nama ?? '',
        email: widget.dataHolder.email ?? '',
        umur: widget.dataHolder.umur ?? 0,
        gender: widget.dataHolder.gender ?? '',
        interest: widget.dataHolder.interest ?? [],
        kodeOtp: '1234',
        location: widget.dataHolder.location ?? [0.0, 0.0],
        photos: widget.dataHolder.photos ?? [],
      );

      // Dapatkan instance Firebase Auth
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Cek apakah user sudah login
      final currentUser = auth.currentUser;
      String userId;

      if (currentUser == null) {
        // User belum login, simpan data tanpa membuat akun Firebase Auth
        // Kita mengasumsikan authentikasinya akan melalui login Google atau nomor telepon
        // Generate random ID untuk sementara
        userId = DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        // User sudah login, gunakan ID user yang ada
        userId = currentUser.uid;
      }

      // Simpan data user ke Firestore
      await UserRepository().addUser(appUser, userId);

      // Jika user sudah login, perbarui sesi
      if (currentUser != null) {
        await SessionManager.saveSession(
          userId: currentUser.uid,
          email: currentUser.email ?? appUser.email,
          name: currentUser.displayName ?? appUser.nama,
        );
      } else {
        // Simpan sesi sementara tanpa login Firebase Auth
        await SessionManager.saveSession(
          userId: userId,
          email: appUser.email,
          name: appUser.nama,
        );
      }

      // Navigate to home
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menyimpan data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 250, 246),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          margin: EdgeInsets.only(right: 48),
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: 0.920,
              backgroundColor: const Color.fromARGB(255, 255, 233, 241),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/LocationImage.png',
                    height: 200,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Enable Your Location',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Choose your location to start find people around you',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 40),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.pink[200],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _isLoading ? null : _getCurrentLocation,
                child:
                    _isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Allow Location Access & Finish',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

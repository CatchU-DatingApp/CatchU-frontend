import 'package:flutter/material.dart';
import '../../home/mainpage.dart';
import 'package:catchu/sign_up_data_holder.dart';
import 'package:catchu/user_model.dart' as app;
import 'package:catchu/user_repository.dart';
import 'package:catchu/services/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:catchu/auth/auth_controller.dart';

class SignUpRulesPage extends StatefulWidget {
  final SignUpDataHolder dataHolder;

  const SignUpRulesPage({super.key, required this.dataHolder});

  @override
  State<SignUpRulesPage> createState() => _SignUpRulesPageState();
}

class _SignUpRulesPageState extends State<SignUpRulesPage> {
  bool _isLoading = false;
  String? _errorMessage;

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
        verified: false,
        location: widget.dataHolder.location ?? [0.0, 0.0],
        photos: widget.dataHolder.photos ?? [],
      );

      // Pastikan email terisi
      if (widget.dataHolder.email == null || widget.dataHolder.email!.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Email harus diisi untuk menyelesaikan pendaftaran';
        });
        return;
      }

      final FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential;
      String uid;

      try {
        // Jika sudah login, gunakan UID yang ada
        if (auth.currentUser != null) {
          uid = auth.currentUser!.uid;
        } else {
          // Generate password otomatis
          String password =
              "${widget.dataHolder.nama?.replaceAll(' ', '_').toLowerCase() ?? 'user'}${widget.dataHolder.phoneNumber?.substring(widget.dataHolder.phoneNumber!.length - 4) ?? '1234'}";

          // Buat user baru dengan email dan password
          userCredential = await auth.createUserWithEmailAndPassword(
            email: widget.dataHolder.email!,
            password: password,
          );
          uid = userCredential.user!.uid;

          // Update profile name
          await userCredential.user!.updateDisplayName(widget.dataHolder.nama);
        }

        // Simpan data user ke Firestore dengan UID dari Firebase Auth
        await UserRepository().addUser(appUser, uid);

        // Save session
        await SessionManager.saveSession(
          userId: uid,
          email: widget.dataHolder.email!,
          name: widget.dataHolder.nama ?? '',
        );

        // Navigate to home
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Jika email sudah digunakan, coba login
          try {
            String password =
                "${widget.dataHolder.nama?.replaceAll(' ', '_').toLowerCase() ?? 'user'}${widget.dataHolder.phoneNumber?.substring(widget.dataHolder.phoneNumber!.length - 4) ?? '1234'}";
            userCredential = await auth.signInWithEmailAndPassword(
              email: widget.dataHolder.email!,
              password: password,
            );
            uid = userCredential.user!.uid;

            // Update data user yang sudah ada
            await UserRepository().addUser(appUser, uid);

            // Save session
            await SessionManager.saveSession(
              userId: uid,
              email: widget.dataHolder.email!,
              name: widget.dataHolder.nama ?? '',
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
                  (route) => false,
            );
          } catch (loginError) {
            setState(() {
              _isLoading = false;
              _errorMessage =
              'Email sudah terdaftar tapi tidak dapat login. Silakan gunakan email lain.';
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error saat membuat akun: ${e.message}';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Gagal menyimpan data: $e';
          _isLoading = false;
        });
      }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/LogoCatchURules.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome to CatchU',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please follow these App Rules',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),

              // Rules
              _buildRuleCard(
                title: 'Be yourself.',
                description:
                'Make sure your photos, age, and bio are true to who you are.',
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                title: 'Stay safe.',
                description:
                "Don't be too quick to give out personal information. ",
                extra: const TextSpan(
                  text: 'Date Safely',
                  style: TextStyle(
                    color: Colors.pink,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                title: 'Play it cool.',
                description:
                'Respect others and treat them as you would like to be treated.',
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                title: 'Be proactive.',
                description: 'Go catch some love :)',
                forceHeight: true,
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finishSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2E63),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.pink[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('I AGREE', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String title,
    required String description,
    TextSpan? extra,
    bool forceHeight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pinkAccent, width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$title\n',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: description),
            if (extra != null) extra,
            if (forceHeight)
              const TextSpan(
                text: '\n',
                style: TextStyle(color: Colors.transparent, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
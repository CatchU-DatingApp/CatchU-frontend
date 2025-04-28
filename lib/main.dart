import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:catchu/services/session_manager.dart';
import 'package:catchu/auth/get_started.dart';
import 'package:catchu/home/homepage1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatchU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: SessionManager.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == true) {
            return DiscoverPage();
          }

          return WelcomeScreen();
        },
      ),
      routes: {
        '/get_started': (context) => WelcomeScreen(),
        '/home': (context) => DiscoverPage(),
      },
    );
  }
}

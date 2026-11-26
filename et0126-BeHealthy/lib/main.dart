import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

bool _firebaseReady = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 4));
    _firebaseReady = true;
  } catch (_) {
    _firebaseReady = false;
  }
  runApp(const BeHealthyApp());
}

class BeHealthyApp extends StatelessWidget {
  const BeHealthyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeHealthy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: false,
      ),
      home: _firebaseReady ? const AuthGate() : const LoginScreen(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

import 'package:blood_donation/pages/LoginForm.dart';
import 'package:blood_donation/pages/MainForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MiddleWare extends StatelessWidget {
  const MiddleWare({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Optional: Show loading indicator while waiting
            }
            if (snapshot.hasData) {
              return MainForm(); // User is logged in
            } else {
              return LoginForm(); // User is not logged in
            }
          },
        ),
      ),
    );
  }
}

import 'package:blood_donation/pages/AboutPage.dart';
import 'package:blood_donation/pages/Dashboard.dart';
import 'package:blood_donation/pages/Donate.dart';
import 'package:blood_donation/pages/HomePage.dart';
import 'package:blood_donation/pages/LoginForm.dart';
import 'package:blood_donation/pages/ListDonors.dart';
import 'package:blood_donation/pages/SignUp.dart';
import 'package:blood_donation/pages/Splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Blood Donation",
      home: SplashScreen()));
}

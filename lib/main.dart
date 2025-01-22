import 'package:blood_donation/pages/MiddleWare.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Blood Donation",
      home: MiddleWare()));
}

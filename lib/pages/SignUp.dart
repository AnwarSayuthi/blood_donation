import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Content/TextfieldWidget.dart';
import '../Content/buttonWidget.dart';
import '../Content/imagewidget.dart';
import '../Content/mytext.dart';
import 'Dashboard.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final email = TextEditingController();
  final password = TextEditingController();
  final password2 = TextEditingController();
  final fullName = TextEditingController();
  final age = TextEditingController();
  final bloodType = TextEditingController();

  bool isLoading = false;

  void clean() {
    email.text = "";
    password.text = "";
    password2.text = "";
    fullName.text = "";
    age.text = "";
    bloodType.text = "";
  }

  Future<void> saveUserDetails(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email.text,
      'fullName': fullName.text,
      'age': age.text,
      'bloodType': bloodType.text,
      'role': 'user',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              const ImageWidget(ImageAsset: 'images/Log.png', ImageHeight: 210),
              MyText(MylableText: "Blood Donation App", FontSize: 30),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    MyTextField(
                      obscureText: false,
                      Control: fullName,
                      HintText: "Full Name",
                      PrefixIcon: const Icon(Icons.person),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      obscureText: false,
                      Control: age,
                      HintText: "Age",
                      PrefixIcon: const Icon(Icons.cake),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Blood Type (Optional)",
                        prefixIcon: const Icon(Icons.bloodtype),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      value:
                          null, // Default value for dropdown (null for no selection)
                      items: [
                        DropdownMenuItem(value: "A+", child: Text("A+")),
                        DropdownMenuItem(value: "A-", child: Text("A-")),
                        DropdownMenuItem(value: "B+", child: Text("B+")),
                        DropdownMenuItem(value: "B-", child: Text("B-")),
                        DropdownMenuItem(value: "AB+", child: Text("AB+")),
                        DropdownMenuItem(value: "AB-", child: Text("AB-")),
                        DropdownMenuItem(value: "O+", child: Text("O+")),
                        DropdownMenuItem(value: "O-", child: Text("O-")),
                      ],
                      onChanged: (value) {
                        // Handle the selected value
                        bloodType.text = value ?? "";
                      },
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      obscureText: false,
                      Control: email,
                      HintText: "Email",
                      PrefixIcon: const Icon(Icons.alternate_email_outlined),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      obscureText: true,
                      Control: password,
                      HintText: "Password",
                      PrefixIcon: const Icon(Icons.lock_outline_rounded),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      obscureText: true,
                      Control: password2,
                      HintText: "Confirm Password",
                      PrefixIcon: const Icon(Icons.lock_outline_rounded),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            )
                          : MyButton(btnText: "Sign Up"),
                      onTap: () async {
                        try {
                          if (password.text == password2.text) {
                            try {
                              isLoading = true;
                              var response = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: email.text,
                                password: password.text,
                              );
                              await saveUserDetails(response.user!.uid);

                              clean();

                              // Show success notification
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color:
                                                Colors.green), // Success icon
                                        SizedBox(
                                            width:
                                                10), // Space between icon and text
                                        const Text(
                                          "Registration Successful",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                        "You have been successfully registered."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Close the dialog
                                          Navigator.pop(
                                              context); // Navigate back to login screen
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } catch (err) {
                              log("Error: $err");
                              // Optionally handle error cases here
                            } finally {
                              isLoading = false;
                            }
                          } else {
                            // Show error dialog for password mismatch
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text(
                                      "Passwords do not match. Please try again."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } catch (err) {
                          log("Error: $err");
                        }
                        isLoading = false;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Have an account? ",
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Click Here",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

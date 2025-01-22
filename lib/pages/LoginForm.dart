import 'dart:developer';

import 'package:blood_donation/Content/TextfieldWidget.dart';
import 'package:blood_donation/Content/buttonWidget.dart';
import 'package:blood_donation/Content/imagewidget.dart';
import 'package:blood_donation/Content/mytext.dart';
import 'package:blood_donation/pages/FogotPasswordPage.dart';
import 'package:blood_donation/pages/MiddleWare.dart';
import 'package:blood_donation/pages/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});
  final username = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;

  void clean() {
    username.text = "";
    password.text = "";
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Prevent overlay when keyboard appears
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const ImageWidget(
                    ImageAsset: 'images/Log.png', ImageHeight: 250),
                MyText(
                  MylableText: "Blood Donation App",
                  FontSize: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        MyTextField(
                          obscureText: false,
                          Control: username,
                          HintText: "Email",
                          PrefixIcon: Icon(Icons.alternate_email_outlined),
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 20),
                        MyTextField(
                          obscureText: true,
                          Control: password,
                          HintText: "Password",
                          PrefixIcon: Icon(Icons.lock_outline_rounded),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordPage()));
                            },
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Forgot your password? ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Click here",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )
                              : MyButton(btnText: "Login"),
                          onTap: () async {
                            try {
                              isLoading = true;
                              var response = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: username.text,
                                      password: password.text);
                              clean();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MiddleWare()));
                            } on FirebaseAuthException catch (e) {
                              log("Error: $e");
                              String errorMessage = "An error occurred";
                              if (e.code == 'user-not-found') {
                                errorMessage = "No user found for this email.";
                              } else if (e.code == 'wrong-password') {
                                errorMessage = "Invalid password.";
                              } else if (e.code == 'invalid-email') {
                                errorMessage = "Invalid email format.";
                              }
                              showSnackBar(context, errorMessage);
                            } catch (e) {
                              log("Unexpected Error: $e");
                              showSnackBar(context,
                                  "Something went wrong. Please try again.");
                            } finally {
                              isLoading = false;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()));
                      },
                      child: const Text(
                        "Sign up now",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Colors.red, // Makes the underline red
                          decorationThickness:
                              1.5, // Optional: Adjust the thickness
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

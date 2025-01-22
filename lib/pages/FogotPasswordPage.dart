import 'package:blood_donation/Content/TextfieldWidget.dart';
import 'package:blood_donation/Content/buttonWidget.dart';
import 'package:blood_donation/Content/imagewidget.dart';
import 'package:blood_donation/Content/mytext.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email.')),
      );
      emailController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset email: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const ImageWidget(
                ImageAsset: 'images/Log.png',
                ImageHeight: 200,
              ),
              const SizedBox(height: 20),
              MyText(
                MylableText: "Forgot Your Password?",
                FontSize: 24,
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your registered email below to reset your password.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: MyTextField(
                  obscureText: false,
                  Control: emailController,
                  HintText: "Email",
                  PrefixIcon: Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await sendPasswordResetEmail(context);
                  }
                },
                child: MyButton(btnText: "Send Reset Link"),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Navigate back to the previous page
                },
                child: const Text(
                  "Back to Login",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.red,
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

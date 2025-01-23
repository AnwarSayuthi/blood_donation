import 'package:blood_donation/Content/imagewidget.dart';
import 'package:blood_donation/pages/LoginForm.dart';
import 'package:blood_donation/pages/UserHomePage.dart'; // Import UserHomePage
import 'package:blood_donation/pages/RecipientHomePage.dart'; // Import RecipientHomePage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';

class MainForm extends StatelessWidget {
  const MainForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const CircularProgressIndicator(); // Show loading indicator while waiting
            // }
            if (snapshot.hasData) {
              // User is signed in
              String email = snapshot.data!.email!;
              return FutureBuilder<String>(
                future:
                    getUserRoleByEmail(email), // Fetch user role based on email
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show loading indicator while fetching role
                  }
                  if (roleSnapshot.hasData) {
                    String userRole = roleSnapshot.data!;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (userRole == "user") {
                        final String? userId =
                            snapshot.data?.uid; // Fetch userId safely
                        if (userId != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserHomePage(userId: userId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Error: User ID is null")),
                          );
                        }
                      } else if (userRole == "recipient") {
                        final String? userId =
                            snapshot.data?.uid; // Fetch userId safely
                        if (userId != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipientHomePage(userId: userId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Error: User ID is null")),
                          );
                        }
                      } else {
                        // Handle unidentified role
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content: const Text("Role Not Identified"),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    // Log out the user
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    });

                    return Container(); // Return an empty container while navigating
                  } else {
                    return const Text(
                        "Error fetching user role."); // Handle error
                  }
                },
              );
            } else {
              // User is not signed in
              return LoginForm(); // Show login form
            }
          },
        ),
      ),
    );
  }

  // Function to get user role by email
  Future<String> getUserRoleByEmail(String email) async {
    // Access Firestore and fetch user document based on email
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email) // Query by email
        .get();

    if (userDoc.docs.isNotEmpty) {
      // If the document exists, return the role
      return userDoc.docs.first.data()['role'] ??
          'unknown'; // Return role or 'unknown' if not found
    } else {
      return 'unknown'; // Return 'unknown' if no document matches
    }
  }
}

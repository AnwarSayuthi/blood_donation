import 'package:blood_donation/pages/LoginForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String userId; // Firebase Auth UID for the current user.
  final Function(int) onPageSelected; // Callback function for navigation.

  const CustomDrawer(
      {super.key, required this.userId, required this.onPageSelected});

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserDetails(userId),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text(""));
        }

        final userDetails = snapshot.data!;
        final String fullName = userDetails['fullName'] ?? 'N/A';
        final String email = userDetails['email'] ?? 'N/A';
        final String role = userDetails['role'] ?? 'user'; // Default to 'user'

        return Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.red),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1, // Restrict to one line
                      overflow: TextOverflow
                          .ellipsis, // Add "..." if text is too long
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text("Home"),
                onTap: () {
                  onPageSelected(0); // Switch to Home page
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                title: const Text("Profile"),
                onTap: () {
                  onPageSelected(1); // Switch to Profile page
                  Navigator.pop(context); // Close the drawer
                },
              ),
              if (role == "user")
                ListTile(
                  title: const Text("Achievement"),
                  onTap: () {
                    onPageSelected(2); // Switch to Achievement page
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              if (role == "recipient")
                ListTile(
                  title: const Text("Find Donor"),
                  onTap: () {
                    onPageSelected(2); // Switch to Find Donor page
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              ListTile(
                title: const Text("Logout"),
                onTap: () async {
                  try {
                    // Perform logout by signing out of Firebase
                    await FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Successfully Logout")),
                    );
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginForm()));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error during logout: ${e.toString()}"),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

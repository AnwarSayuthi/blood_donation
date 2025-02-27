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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                leading: const Icon(Icons.home, color: Colors.red),
                title: const Text("Home"),
                onTap: () {
                  onPageSelected(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.red),
                title: const Text("Profile"),
                onTap: () {
                  onPageSelected(1);
                  Navigator.pop(context);
                },
              ),
              if (role == "user")
                ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.red),
                  title: const Text("Achievement"),
                  onTap: () {
                    onPageSelected(2);
                    Navigator.pop(context);
                  },
                ),
              if (role == "recipient")
                ListTile(
                  leading: const Icon(Icons.search, color: Colors.red),
                  title: const Text("Find Donor"),
                  onTap: () {
                    onPageSelected(2);
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
                onTap: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Successfully Logout")),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginForm()),
                    );
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

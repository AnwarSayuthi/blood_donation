import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedBloodType;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  // Get authenticated user's email and fetch Firestore data
  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
      });
      _fetchUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated.')),
      );
    }
  }

  // Fetch user data from Firestore based on email
  Future<void> _fetchUserData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        setState(() {
          _fullNameController.text = userData['fullName'] ?? '';
          _ageController.text = userData['age'] ?? '';
          _selectedBloodType = userData['bloodType'] ?? 'O+';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    }
  }

  // Update user profile
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _userEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(querySnapshot.docs.first.id)
              .update({
            'fullName': _fullNameController.text.trim(),
            'age': _ageController.text.trim(),
            'bloodType': _selectedBloodType,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    TextFormField(
                      initialValue: _userEmail,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Full Name',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter full name',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter full name' : null,
                    ),
                    SizedBox(height: 16),
                    Text('Age',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter age',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter age' : null,
                    ),
                    SizedBox(height: 16),
                    Text('Blood Type',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
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
                        setState(() {
                          _selectedBloodType = value;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Save', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

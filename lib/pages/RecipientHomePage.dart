import 'package:blood_donation/Content/CustomDrawer.dart';
import 'package:blood_donation/pages/FindDonor.dart';
import 'package:blood_donation/pages/HomePage.dart';
import 'package:blood_donation/pages/ProfilePage.dart';
import 'package:flutter/material.dart';

class RecipientHomePage extends StatefulWidget {
  final String userId;

  const RecipientHomePage({super.key, required this.userId});

  @override
  State<RecipientHomePage> createState() => _RecipientHomePageState();
}

class _RecipientHomePageState extends State<RecipientHomePage> {
  int _selectedIndex = 0; // To track the current page

  // List of titles corresponding to each page
  final List<String> _pageTitles = ["Home", "Profile", "Find Donor"];

  // Helper method to generate a new instance of the selected page
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage(); // Create a new instance of HomePage
      case 1:
        return ProfilePage(); // Create a new instance of ProfilePage
      case 2:
        return FindDonorPage(); // Create a new instance of FindDonorPage
      default:
        return const SizedBox.shrink(); // Fallback widget
    }
  }

  // Function to update the current index
  void _updatePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(_pageTitles[_selectedIndex]), // Dynamic title
      ),
      drawer: CustomDrawer(
        userId: widget.userId,
        onPageSelected: _updatePage, // Pass the callback function
      ),
      body: _getPage(_selectedIndex), // Dynamically rebuild the selected page
    );
  }
}

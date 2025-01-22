import 'package:blood_donation/pages/LocationPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userRole;
  String? userBloodType;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userRole = querySnapshot.docs.first['role'];
          userBloodType = querySnapshot.docs.first['bloodType'];

          isLoading = false;
        });
      }
    }
  }

  void _navigateToLocationPage(String documentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPage(docID: documentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('donates')
                  .where('donated_by', isNull: true)
                  .where('bloodType', isEqualTo: userBloodType)
                  .orderBy('createdAt', descending: true)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No blood donation requests available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final donations = snapshot.data!.docs;

                // print("Number of donation rows: ${donations.length}");

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation =
                        donations[index].data() as Map<String, dynamic>;
                    final address =
                        donation['selectedHospital']['address_text'] ?? '';
                    final bloodType = donation['bloodType'] ?? '';
                    final recipientName = donation['recipientName'] ?? '';
                    final requestorName = donation['requestorName'] ?? '';
                    final documentId = donations[index].id;

                    final hospitalName = address.split(',').first;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hospital Name with Icon
                            Row(
                              children: [
                                Icon(Icons.local_hospital,
                                    color: Colors.redAccent),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hospitalName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Recipient and Requestor Name
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Recipient: $recipientName',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.account_circle, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Requestor: $requestorName',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Blood Type and Action Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Blood Type Display
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.redAccent),
                                  ),
                                  child: Text(
                                    bloodType,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),

                                // View Details Button
                                ElevatedButton.icon(
                                  onPressed: userRole == 'user'
                                      ? () =>
                                          _navigateToLocationPage(documentId)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    disabledBackgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  icon: Icon(Icons.visibility),
                                  label: Text('View Details'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

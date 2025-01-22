import 'package:blood_donation/pages/MainForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  final String docID;

  const LocationPage({required this.docID, Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Map<String, dynamic>? donationData;
  bool isLoading = true;
  LatLng? hospitalLocation;

  @override
  void initState() {
    super.initState();
    _fetchDonationDetails();
  }

  Future<void> _fetchDonationDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('donates')
          .doc(widget.docID)
          .get();

      if (doc.exists) {
        setState(() {
          donationData = doc.data();
          isLoading = false;
        });

        // Convert latitude and longitude from Firestore (stored as strings)
        _setHospitalLocation(
          donationData!['selectedHospital']['lat'],
          donationData!['selectedHospital']['lon'],
        );
      }
    } catch (e) {
      print('Error fetching donation details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setHospitalLocation(String lat, String lon) {
    try {
      double latitude = double.parse(lat);
      double longitude = double.parse(lon);
      setState(() {
        hospitalLocation = LatLng(latitude, longitude);
      });
    } catch (e) {
      print('Error parsing coordinates: $e');
    }
  }

  Future<void> _handleDonation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('donates')
          .doc(widget.docID)
          .update({'donated_by': user.email});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you! Your help has been recorded.')),
      );
      // Navigate to HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainForm()),
      );
    } catch (e) {
      print('Error updating donation: $e');
    }
  }

  // Function to extract hospital name from address_text
  String getHospitalName(String? addressText) {
    if (addressText == null || addressText.isEmpty) {
      return 'Unknown Hospital';
    }
    return addressText.split(',')[0]; // Extract first part before the comma
  }

  // Function to format timestamp difference
  String getTimeDifference(Timestamp? createdAt) {
    if (createdAt == null) {
      return 'Unknown Time';
    }

    DateTime createdDateTime = createdAt.toDate();
    Duration difference = DateTime.now().difference(createdDateTime);

    if (difference.inMinutes < 1) {
      return 'New';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    String hospitalAddress =
        donationData?['selectedHospital']?['address_text'] ?? 'Unknown Address';
    String hospitalName = getHospitalName(hospitalAddress);

    // Check if `createdAt` is available and handle null case
    Timestamp? createdAt = donationData?['createdAt'];
    String timeAgoText = getTimeDifference(createdAt);

    // Set text color conditionally
    Color textColor = timeAgoText == 'New' ? Colors.green : Colors.grey[600]!;
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Donation Details'),
          backgroundColor: Colors.redAccent,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (donationData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Donation Details'),
          backgroundColor: Colors.redAccent,
        ),
        body: Center(child: Text('No donation data found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Text(
              hospitalName ?? 'Hospital',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              timeAgoText,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Details Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Recipient Name: ${donationData!['recipientName']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Requestor Name: ${donationData!['requestorName']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Blood Type: ${donationData!['bloodType']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gender: ${donationData!['gender']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Phone Number: ${donationData!['phoneNumber']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Address: ${donationData!['selectedHospital']['address_text']}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Map Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: hospitalLocation != null
                    ? FlutterMap(
                        options: MapOptions(
                          initialCenter: hospitalLocation ??
                              LatLng(0.0, 0.0), // Default value if null
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'com.example.blood_donation',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: hospitalLocation ?? LatLng(0.0, 0.0),
                                child: Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Center(child: Text('Unable to load map location')),
              ),
            ),
            SizedBox(height: 16),

            // Donation Button
            ElevatedButton(
              onPressed:
                  donationData!['donated_by'] == null ? _handleDonation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'I can help',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

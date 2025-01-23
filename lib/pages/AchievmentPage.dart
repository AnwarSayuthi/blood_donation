import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  int donationCount = 0;
  String achievementLevel = "Beginner Donor";
  bool isLoading = true;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> donationHistory = [];
  DocumentSnapshot? lastDocument;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialDonations();
  }

  Future<void> _fetchInitialDonations() async {
    setState(() => isLoading = true);
    await _fetchDonations();
    setState(() => isLoading = false);
  }

  Future<void> _fetchDonations({bool loadMore = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && hasMore) {
      setState(() => isLoadingMore = loadMore);

      Query query = FirebaseFirestore.instance
          .collection('donates')
          .where('donated_by', isEqualTo: user.email)
          .orderBy('createdAt', descending: true)
          .limit(5);

      if (loadMore && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final querySnapshot = await query.get();

      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          lastDocument = querySnapshot.docs.last;
          donationHistory.addAll(querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());
        } else {
          hasMore = false;
        }

        donationCount = donationHistory.length;
        achievementLevel = _getAchievementLevel(donationCount);
        isLoadingMore = false;
      });
    }
  }

  String _getAchievementLevel(int count) {
    if (count > 50) return "Legendary Donor";
    if (count > 20) return "Champion Donor";
    if (count > 10) return "Regular Donor";
    if (count >= 5) return "Intermediate Donor";
    return "Beginner Donor";
  }

  int _donationsToNextLevel(int count) {
    if (count >= 50) return 0;
    if (count >= 20) return 51 - count;
    if (count >= 10) return 21 - count;
    if (count >= 5) return 11 - count;
    return 5 - count;
  }

  double _progressToNextLevel(int count) {
    if (count >= 50) return 1.0;
    if (count >= 20) return (count - 20) / 30;
    if (count >= 10) return (count - 10) / 10;
    if (count >= 5) return (count - 5) / 5;
    return count / 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section with Donation Levels
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(
                              255, 252, 205, 208), // Light red theme start
                          Color.fromARGB(
                              255, 252, 205, 208), // Light red theme start
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          achievementLevel,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "$donationCount Donations",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Progress Bar
                        LinearProgressIndicator(
                          value: _progressToNextLevel(donationCount)
                              .clamp(0.0, 1.0),
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.deepOrangeAccent),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${_donationsToNextLevel(donationCount)} donations to next level",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Donation History Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Donation History",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Donation History List
                        donationHistory.isEmpty
                            ? Center(
                                child: Text(
                                  "No donations found.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: donationHistory.length,
                                itemBuilder: (context, index) {
                                  final donation = donationHistory[index];
                                  final hospitalName =
                                      donation['selectedHospital']
                                              ['address_text']
                                          .split(',')
                                          .first;
                                  final createdAt =
                                      (donation['createdAt'] as Timestamp)
                                          .toDate();
                                  final dateString =
                                      "${createdAt.day}/${createdAt.month}/${createdAt.year}";

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.local_hospital,
                                        color: Colors.redAccent,
                                        size: 36,
                                      ),
                                      title: Text(
                                        hospitalName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Date: $dateString"),
                                          Text(
                                              "Recipient: ${donation['recipientName']}")
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                        if (isLoadingMore)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:blood_donation/pages/MainForm.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindDonorPage extends StatefulWidget {
  const FindDonorPage({super.key});

  @override
  State<FindDonorPage> createState() => _FindDonorPageState();
}

class _FindDonorPageState extends State<FindDonorPage> {
  final _formKey = GlobalKey<FormState>();
  String? _recipientName;
  String? _requestorName;
  String? _phoneNumber;
  String? _gender;
  String? _bloodType;
  String? _yearOfBirth;
  List<Map<String, String>> hospitals = [];
  Map<String, String>? _selectedHospital;
  bool _isLoading = true; // Initially true to show the loading screen.

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Fetches user details and nearby hospitals simultaneously.
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true; // Show loading screen.
    });

    try {
      await Future.wait([
        _fetchUserDetails(),
        fetchNearbyHospitals(),
      ]);
    } catch (e) {
      print("Error during data loading: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading screen after all tasks complete.
        });
      }
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No authenticated user found");
      }

      final String email = user.email!;
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _recipientName = userData['fullName'] ?? "Unknown";
          });
        }
      } else {
        throw Exception("User document not found");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recipientName = "Error fetching user";
        });
      }
      print("Error fetching user details: $e");
    }
  }

  Future<List<Map<String, String>>> fetchHospitalsByPrompts(
      List<String> prompts) async {
    const String nominatimUrl = 'https://nominatim.openstreetmap.org/search';
    Set<Map<String, String>> uniqueHospitals = {};

    for (String prompt in prompts) {
      final uri = Uri.parse(nominatimUrl).replace(queryParameters: {
        'q': prompt,
        'format': 'json',
        'limit': '10',
        'addressdetails': '1',
      });

      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);

          for (var hospital in data) {
            final name = hospital['display_name'] ?? 'Unknown';
            final address = hospital['address']?.toString() ?? 'No address';
            final url = hospital['osm_id']?.toString() ?? '';
            final lat = hospital['lat']?.toString() ?? '';
            final lon = hospital['lon']?.toString() ?? '';

            if (url.isNotEmpty && lat.isNotEmpty && lon.isNotEmpty) {
              uniqueHospitals.add({
                'name': name,
                'address': address,
                'url': url,
                'lat': lat,
                'lon': lon,
              });
            }
          }
        } else {
          print(
              'Error fetching hospitals for prompt "$prompt": ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching hospitals for prompt "$prompt": $e');
      }
    }

    // Convert Set to List
    List<Map<String, String>> hospitalList = uniqueHospitals.toList();

    // Sort hospitals alphabetically by name
    hospitalList.sort((a, b) => a['name']!.compareTo(b['name']!));

    return hospitalList;
  }

  Future<void> fetchNearbyHospitals() async {
    const List<String> prompts = [
      'batu pahat hospitals',
      // 'Johor Bahru Hospitals',
      // 'kluang hospitals malaysia',
      // 'Kota Tinggi Hospitals',
      // 'Mersing Hospitals',
      // 'Tangkak Hospitals',
      // 'Muar Hospitals',
      // 'Pontian Hospitals',
      // 'Segamat Hospitals',
    ];
    try {
      List<Map<String, String>> nearbyHospitals =
          await fetchHospitalsByPrompts(prompts);

      if (mounted) {
        setState(() {
          hospitals = nearbyHospitals;
        });
      }
    } catch (e) {
      print("Error fetching hospitals: $e");
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final donationData = {
        "requestorName": _requestorName,
        "recipientName": _recipientName,
        "phoneNumber": _phoneNumber,
        "gender": _gender,
        "bloodType": _bloodType,
        "yearOfBirth": _yearOfBirth,
        "selectedHospital": {
          "address_text": _selectedHospital?['name'] ?? '',
          "address_id": _selectedHospital?['url'] ?? '',
          "lat": _selectedHospital?['lat'] ?? '',
          "lon": _selectedHospital?['lon'] ?? '',
        },
        "createdAt": FieldValue.serverTimestamp(),
        "donated_by": null,
      };

      try {
        await FirebaseFirestore.instance
            .collection('donates')
            .add(donationData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Donation request submitted successfully!"),
          ),
        );

        // Navigate to HomePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainForm()),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit request: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show loading screen while data is loading.
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Render the main content after loading.
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Requestor Name",
                  hintText: "Enter your name",
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _requestorName = value,
                validator: (value) =>
                    value!.isEmpty ? "Requestor Name is required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _recipientName,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Recipient Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  hintText: "Enter your phone number",
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _phoneNumber = value,
                validator: (value) =>
                    value!.isEmpty ? "Phone Number is required" : null,
              ),
              const SizedBox(height: 16),
              const Text("Gender",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Male"),
                      value: "Male",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value as String;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Female"),
                      value: "Female",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value as String;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Type of Blood Required",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                items: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
                    .map((bloodType) {
                  return DropdownMenuItem(
                    value: bloodType,
                    child: Text(bloodType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _bloodType = value;
                  });
                },
                onSaved: (value) => _bloodType = value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? "Blood type is required" : null,
              ),
              const SizedBox(height: 16),
              const Text("Year of Birth",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter your year of birth",
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _yearOfBirth = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Year of Birth is required";
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year) {
                    return "Enter a valid year";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text("Select Hospital",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<Map<String, String>>(
                isExpanded: true,
                items: hospitals.asMap().entries.map((entry) {
                  final index = entry.key;
                  final hospital = entry.value;

                  return DropdownMenuItem(
                    value: hospital,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2, // Restrict max lines
                        ),
                        if (index !=
                            hospitals.length -
                                1) // Add divider unless it's the last item
                          const Divider(
                            thickness: 1,
                            height: 10,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHospital = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) =>
                    value == null ? "Please select a nearby hospital" : null,
                dropdownColor:
                    Colors.white, // Optional: Set dropdown background color
                selectedItemBuilder: (BuildContext context) {
                  // Customize the selected item display
                  return hospitals.map((hospital) {
                    return Text(
                      hospital['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    );
                  }).toList();
                },
                menuMaxHeight: 300, // Set max height for the dropdown
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: _handleSubmit,
                child: const Text(
                  "Send",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

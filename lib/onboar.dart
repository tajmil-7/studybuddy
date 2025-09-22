import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/crtacc.dart';
import 'package:studybuddy/main.dart';
import 'package:studybuddy/mentor_skill.dart';
import 'package:studybuddy/mentorpage.dart';
import 'package:studybuddy/student_skill.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required String uid});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late Future<DocumentSnapshot> _userDocFuture;
  bool _isLoading = false;

  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _universityid = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userDocFuture = _getUserDocument();
  }

  Future<DocumentSnapshot> _getUserDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  Future<void> _completeOnboarding(String role) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }

      final skillsList =
          _skillsController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      if (role == 'student') {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'degree': _degreeController.text,
          'year': _yearController.text,
          'bio': _bioController.text,
          'skills': skillsList,
          'studentRegistrationNumber': _registrationNumberController.text,
          'completedOnboarding': true,
        }, SetOptions(merge: true));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AuthGate()),
          );
        }
      } else if (role == 'mentor') {
        await FirebaseFirestore.instance
            .collection('mentors')
            .doc(user.uid)
            .set({
              'degree': _degreeController.text,
              'year': _yearController.text,
              'bio': _bioController.text,
              'skills': skillsList,
              'staffId': _staffIdController.text,
              'completedOnboarding': true,
            });

        if (mounted) {
          // This is where the app navigates to the MentorSkillPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MentorSelectionPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF1E2A3A),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateAccountPage(),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userDocFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          final role = snapshot.data!['role']?.toString().toLowerCase();

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Complete your profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A3A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please provide your details to get started.",
                    style: TextStyle(fontSize: 16, color: Color(0xFF5E6772)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(_degreeController, "Degree"),
                  const SizedBox(height: 16),
                  _buildTextField(_yearController, "Year"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _bioController,
                    "Bio (e.g., your interests and goals)",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _skillsController,
                    "Skills (comma-separated, e.g., 'Dart, Firebase')",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_contactController, "Contact Number"),

                  const SizedBox(height: 16),
                  _buildTextField(_universityid, "University Name"),
                  const SizedBox(height: 16),
                  if (role == 'student')
                    _buildTextField(
                      _registrationNumberController,
                      "Student Registration Number",
                    ),
                  if (role == 'mentor')
                    _buildTextField(_staffIdController, "Staff ID"),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _completeOnboarding(role!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Complete Onboarding",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2.0),
          ),
        ),
      ),
    );
  }
}

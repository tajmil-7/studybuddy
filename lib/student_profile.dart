import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Assuming AuthGate and other imports from your previous context are available
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/main.dart'; // Assuming AuthGate is defined here

class StudentProfileApp extends StatelessWidget {
  const StudentProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Profile',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D9FE6),
        scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7F8),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: const Color(0xFF2D9FE6),
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 8.0,
        ),
      ),
      home: const StudentProfilePage(),
    );
  }
}

class StudentProfilePage extends StatefulWidget {
  // Use a final variable to hold the student's UID
  final String studentUid;
  const StudentProfilePage({super.key, this.studentUid = ''});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _studentFuture;

  @override
  void initState() {
    super.initState();
    // Use the current authenticated user's UID to fetch their profile
    final currentUser = FirebaseAuth.instance.currentUser;
    _studentFuture =
        FirebaseFirestore.instance
            .collection('users')
            .doc(
              widget.studentUid.isNotEmpty
                  ? widget.studentUid
                  : currentUser?.uid,
            )
            .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Handle edit profile action
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Student data not found."));
          }

          final student = snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(student),
                const SizedBox(height: 16),
                _buildBio(student),
                const SizedBox(height: 16),
                _buildSkillsSection(student),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Academic Details',
                  child: Column(
                    children: [
                      _buildDetailRow('Major', student['major'] ?? 'N/A'),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Student ID',
                        student['studentId'] ?? 'N/A',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow('GPA', student['gpa'] ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => AuthGate()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 58, 126, 228),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              student['avatar'] ?? 'https://i.pravatar.cc/150?img=5',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            student['firstName'] ?? 'No Name',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            student['university'] ?? 'University',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            student['year'] ?? 'N/A',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBio(Map<String, dynamic> student) {
    return _buildInfoCard(
      title: 'About',
      child: Text(
        student['bio'] ?? 'No bio available',
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade800,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSkillsSection(Map<String, dynamic> student) {
    final List<String> skills =
        (student['skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    if (skills.isEmpty) return const SizedBox();

    return _buildInfoCard(
      title: 'Skills & Expertise',
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children:
            skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.blue[50],
                    labelStyle: const TextStyle(color: Colors.blue),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

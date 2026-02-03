import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> mentorBuilder() async {
  final querySnapshot = await db.collection("users").get();
  List<Map<String, dynamic>> mentors = [];
  for (var doc in querySnapshot.docs) {
    if (doc["role"] == "mentor") {
      mentors.add(doc.data());
    }
  }
  return mentors;
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recommended Mentors Section
                const Text(
                  "Recommended Mentors",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: mentorBuilder(), // <-- call it here
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No mentors found.');
                      }

                      final mentors = snapshot.data!;
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: mentors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final m = mentors[index];
                          return _buildMentorCard(
                            m['firstName'] ?? 'Unknown',
                            m['subject'] ?? '',
                            m['photoUrl'] ??
                                'https://picsum.photos/seed/$index/200/200',
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Upcoming Appointments Section
                const Text(
                  "Upcoming Appointments",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAppointmentCard(
                  'Mentorship Session with Liam Harper',
                  '10:00 AM - 11:00 AM',
                  'https://picsum.photos/seed/liam/200/200',
                ),
                const SizedBox(height: 24),
                // Quick Access Section
                const Text(
                  "Quick Access",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickAccessGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMentorCard(String name, String subject, String imageUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[200],
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A3A),
          ),
        ),
        Text(subject, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildAppointmentCard(String title, String time, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildQuickAccessCard(
          Icons.code,
          'Popular Skills',
          const Color(0xFF4285F4),
        ),
        _buildQuickAccessCard(
          Icons.group,
          'New Mentors',
          const Color(0xFF4285F4),
        ),
        _buildQuickAccessCard(
          Icons.edit,
          'Browse All',
          const Color(0xFF4285F4),
        ),
        _buildQuickAccessCard(
          Icons.people,
          'Community',
          const Color(0xFF4285F4),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(IconData icon, String title, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A3A),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

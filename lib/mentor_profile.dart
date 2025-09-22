import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/main.dart';

class MentorProfilePage extends StatefulWidget {
  final String mentorUid; // UID of the mentor document

  const MentorProfilePage({super.key, required this.mentorUid, required Map<String, dynamic> mentorData});

  @override
  State<MentorProfilePage> createState() => _MentorProfilePageState();
}

class _MentorProfilePageState extends State<MentorProfilePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _mentorFuture;

  @override
  void initState() {
    super.initState();
    _mentorFuture =
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.mentorUid)
            .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Mentor Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[200],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _mentorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Mentor data not found."));
          }

          final mentor = snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(mentor),
                const SizedBox(height: 16),
                _buildInfoRow('Degree', mentor['degree'] ?? 'N/A'),
                _buildInfoRow('Year', mentor['year'] ?? 'N/A'),
                _buildInfoRow('Staff ID', mentor['staffId'] ?? 'N/A'),
                _buildInfoRow('Contact', mentor['contact'] ?? 'N/A'),
                _buildWorkHours(mentor['workHours']),
                const SizedBox(height: 16),
                _buildBio(mentor),
                const SizedBox(height: 16),
                _buildSkillsSection(mentor),
                const SizedBox(height: 16),
                _buildReviewsSection(mentor),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthGate()),
                    );
                  },
                  child: Text('logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> mentor) {
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
              mentor['avatar'] ??
                  'https://placehold.co/100x100/A0C4FF/000000?text=NA',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mentor['firstName'] ?? 'No Name',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            mentor['bio'] ?? 'Expert Mentor',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.message, size: 18),
            label: const Text('Message Mentor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWorkHours(Map<String, dynamic>? workHours) {
    if (workHours == null || workHours.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Work Hours', style: TextStyle(color: Colors.grey)),
          Text(
            '${workHours['start'] ?? 'N/A'} - ${workHours['end'] ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBio(Map<String, dynamic> mentor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Mentor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(mentor['bio'] ?? 'No bio available'),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(Map<String, dynamic> mentor) {
    final List<String> skills =
        (mentor['skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    if (skills.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills & Expertise',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
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
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Map<String, dynamic> mentor) {
    final List<dynamic> reviews = mentor['reviews'] ?? [];
    if (reviews.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...reviews.map((review) {
            return ReviewCard(
              imageUrl:
                  'https://placehold.co/50x50/E0E0E0/000000?text=${review['name'][0]}',
              name: review['firstName'],
              time: review['time'],
              rating: review['rating'],
              review: review['review'],
              likes: review['likes'],
            );
          }).toList(),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String time;
  final int rating;
  final String review;
  final int likes;

  const ReviewCard({
    required this.imageUrl,
    required this.name,
    required this.time,
    required this.rating,
    required this.review,
    required this.likes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 18),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review, style: TextStyle(color: Colors.grey[800], height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.thumb_up_alt_outlined,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text('$likes'),
            ],
          ),
        ],
      ),
    );
  }
}

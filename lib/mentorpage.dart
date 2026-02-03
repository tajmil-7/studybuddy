import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/main.dart';

class MentorSelectionPage extends StatefulWidget {
  const MentorSelectionPage({super.key});

  @override
  _MentorSelectionPageState createState() => _MentorSelectionPageState();
}

class _MentorSelectionPageState extends State<MentorSelectionPage> {

  final List<Map<String, String>> mentors = [
    {
      "name": "Dr. Anya Sharma",
      "domain": "Expert in Data Science",
      "imageUrl":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuB9fAxK7J7WmuY3agFY-G7iLtRuFo2F-7FpAgwE36pm2YRyyBKdRc7mpmGCQ_6JUTYxkbJhi4Fyc8Inja5jwcKDSiGPxNFkvZUNaf1ApmZHufdZGR1sDkfawS3Yw0YKISlU8ZfgqSThoOef2y_JQjDD0M6nbsi81iazV0sRT7ONwCwdsYP1UHWDJTKXJQSU8xRHEkj-JVliMHZZg-ZNOEZq4lmoa5WoUg9tnU_7b14z2vIeVpVmG_5csboT0p0YOagRc0S0nPd52WQ",
    },
    {
      "name": "Mr. Ben Carter",
      "domain": "Specialist in Software Engineering",
      "imageUrl":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAOw5dk8j3EVUJheIp-1aOYOmTjz1YjrGIbc9Pdt2yMEvFWcet1Aw3aqxGWc6FHFBO_huVylBGQ0eafwqpg5XW7m-hwGD_dabpuO3vld7WHAf3WgXXVjgkQ7Ey-zYmFPBzXT4lLW3yn7Vsx2SCHy_hl9dB8VluDuIq7XHiiU1LHBZRLM4ojQIxuQ7kpi0l2x70vEzs1v6lUBBw_cdX2dumrq1C25YhRHu0-muWoTi0QS1aRrvaCIw9QkW8PoQCaOh_spYYlpFMrLRQ",
    },
    {
      "name": "Ms. Chloe Davis",
      "domain": "Experienced in Product Management",
      "imageUrl":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDew3d_oMJEFqDQ6voyX0epRc_wVIcs1YM-MMzbY-3Wq2o0WbNQlLuYmbQsGiroqQdd5cNcZhiG9xF1s-FmBdAXM_kddMBCOq_XxCnk_rPeQ7COs6U-JJuoeUQnOMdozgA5ncdtF5dqJNZqn8QsY_HhqZWAP3ocC3hnjt_jt11NfyDSvj5sfjq-TWYtYdfhOTMbYjnUsCbuSHZcdleQRHfHF4ZwCVf-8WdWUaekpJNTOZ3b0zPmg6DDZaYSEmAhApvyo9Ecq8LcgZE",
    },
    {
      "name": "Mr. Ethan Foster",
      "domain": "Knowledgeable in UX/UI Design",
      "imageUrl":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBpixpic2UTNhS_sYiUq03tYL6w_paWx0l0DXsJYOKcIrhi9-UP9fhL6vo_D5EK9jEEEwLoW_kYDtP0xmxYkWXFhh6k9IE2f-mvbwMgTEDhBDrHwjbEV3VYfPRHRY8MeXZOELX6659-le0xPKEfpBdyugec7mJQ57XWVPIxUiBlur_22auF67VydTP48D-AxATf2QGuudGgWhvJKUhnS_COeJfzwfEH0TlOAgtZcIaF4S3Lr3-LpmdpR-lPIF3myCzEZz6s5RTh8tk",
    },
  ];

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        title: Text(
          'Mentors',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // Navigate back to login page (or replace with AuthGate)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) =>  AuthGate()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for mentors',
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterButton('Domain'),
                SizedBox(width: 8),
                _buildFilterButton('Availability'),
                SizedBox(width: 8),
                _buildFilterButton('Trust Score'),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                final mentor = mentors[index];
                return MentorCard(
                  name: mentor["name"]!,
                  domain: mentor["domain"]!,
                  imageUrl: mentor["imageUrl"]!, mentor: {},
                );
              },
            ),
          ),
        ],
      ),
      
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF13a4ec).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(text, style: TextStyle(color: Color(0xFF101c22))),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: Color(0xFF101c22), size: 20),
        ],
      ),
    );
  }
}

class MentorCard extends StatelessWidget {
  final String name;
  final String domain;
  final String imageUrl;

  const MentorCard({super.key, 
    required this.name,
    required this.domain,
    required this.imageUrl, required Map<String, dynamic> mentor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundImage: NetworkImage(imageUrl)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF101c22),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  domain,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF13a4ec),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('View'),
          ),
        ],
      ),
    );
  }
}

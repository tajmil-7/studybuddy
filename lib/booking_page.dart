import 'package:flutter/material.dart';

void main() {
  runApp(const MentorApp());
}

class MentorApp extends StatelessWidget {
  const MentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mentor Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7F8),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
      home: const MentorBookingScreen(),
    );
  }
}

class MentorBookingScreen extends StatefulWidget {
  const MentorBookingScreen({super.key});

  @override
  State<MentorBookingScreen> createState() => _MentorBookingScreenState();
}

class _MentorBookingScreenState extends State<MentorBookingScreen> {
  int _selectedIndex = 2; // 'Explore' is the selected tab

  final List<String> _skills = ['Select a Skill', 'Mathematics', 'Physics', 'English', 'History', 'Programming', 'Data Science'];
  final List<String> _timeSlots = ['Select a Time Slot', '9:00 am - 12:00 pm', '1:00 pm - 4:00 pm', '6:00 pm - 9:00 pm'];
  
  String? _selectedSkill;
  String? _selectedPreferredSkill;
  String? _selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: null, // Disabled for UI demonstration
        ),
        title: const Text('Book a Mentor'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Select a Skill Dropdown
          _buildDropdown(_skills, _selectedSkill, 'Select a Skill', (value) {
            setState(() {
              _selectedSkill = value;
            });
          }),
          const SizedBox(height: 24),

          // Available Mentors Section
          _buildSectionTitle('Available Mentors'),
          const SizedBox(height: 16),
          const MentorListTile(
            name: 'Ethan Harper',
            expertise: 'Expert in Math, Physics',
            imageUrl: 'https://i.pravatar.cc/150?img=12',
          ),
          const SizedBox(height: 12),
          const MentorListTile(
            name: 'Sophia Bennett',
            expertise: 'Specialist in English, History',
            imageUrl: 'https://i.pravatar.cc/150?img=5',
          ),
          const SizedBox(height: 12),
          const MentorListTile(
            name: 'Liam Carter',
            expertise: 'Experienced in Programming, Data Science',
            imageUrl: 'https://i.pravatar.cc/150?img=8',
          ),
          const SizedBox(height: 24),

          // Booking Details Section
          _buildSectionTitle('Booking Details'),
          const SizedBox(height: 16),
          _buildBookingForm(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2D9FE6),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBookingForm() {
    return Column(
      children: [
        const TextField(
          decoration: InputDecoration(hintText: 'Your Name'),
        ),
        const SizedBox(height: 16),
        _buildDropdown(_skills, _selectedPreferredSkill, 'Preferred Skill', (value) {
          setState(() {
            _selectedPreferredSkill = value;
          });
        }),
        const SizedBox(height: 16),
        _buildDropdown(_timeSlots, _selectedTimeSlot, 'Select a Time Slot', (value) {
          setState(() {
            _selectedTimeSlot = value;
          });
        }),
        const SizedBox(height: 16),
        const TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(hintText: 'Contact Email'),
        ),
        const SizedBox(height: 16),
        const TextField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(hintText: 'Phone Number'),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D9FE6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Book Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedValue, String hint, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hint, style: TextStyle(color: Colors.grey.shade500)),
      isExpanded: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value == hint ? null : value,
          child: Text(value, style: value == hint ? TextStyle(color: Colors.grey.shade500) : null),
        );
      }).toList(),
    );
  }
}

class MentorListTile extends StatelessWidget {
  final String name;
  final String expertise;
  final String imageUrl;

  const MentorListTile({
    super.key,
    required this.name,
    required this.expertise,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expertise,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}
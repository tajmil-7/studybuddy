// main_wrapper.dart

import 'package:flutter/material.dart';

// Import all pages for both roles
import 'package:studybuddy/home_page.dart';
import 'package:studybuddy/StMlist.dart';
import 'package:studybuddy/chatbot.dart';
import 'package:studybuddy/student_profile.dart';
import 'package:studybuddy/mentorpage.dart';
import 'package:studybuddy/std_ment_prof.dart';
import 'package:studybuddy/booking_page.dart'; // Import the booking page

class MainWrapper extends StatefulWidget {
  final String userRole;
  final String userUid;
  const MainWrapper({super.key, required this.userRole, required this.userUid});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  late final List<Widget> _studentPages;
  late final List<Widget> _mentorPages;

  @override
  void initState() {
    super.initState();
    _studentPages = [
      const HomePage(),
      const SMentorsListPage(),
      const ChatScreen(),
      const StudentProfileApp(),
    ];
    _mentorPages = [
      const MentorSelectionPage(),
      const Text('Students List Page'), // Placeholder for students list
      const BookingPage(), // Use the BookingPage for mentors
      LMentorProfilePage(
        mentorUid: widget.userUid,
        mentorData: const {},
        isNavigatedFromMentorsList: false,
      ),
    ];
  }

  final List<BottomNavigationBarItem> _studentNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Mentors'),
    BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: 'ChatBot'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  final List<BottomNavigationBarItem> _mentorNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
    BottomNavigationBarItem(
      icon: Icon(Icons.event_note),
      label: 'Bookings',
    ), // Changed from ChatBot to Bookings
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isStudent = widget.userRole == 'student';

    final List<Widget> pages = isStudent ? _studentPages : _mentorPages;
    final List<BottomNavigationBarItem> navItems =
        isStudent ? _studentNavItems : _mentorNavItems;

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:studybuddy/StMlist.dart';
import 'package:studybuddy/chatbot.dart';
import 'package:studybuddy/home_page.dart';
import 'package:studybuddy/student_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages corresponding to BottomNavigationBar items
  final List<Widget> _pages = [
    HomePage(),
    SMentorsListPage(),
    ChatScreen(),
    StudentProfileApp(),
  ];

  // Update selected index on tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Show selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Mentor'),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: 'ChatBot',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF13a4ec),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}

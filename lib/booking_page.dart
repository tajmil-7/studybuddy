// booking_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Renamed from MentorBookingScreen to BookingPage for clarity.
// This widget no longer has its own Scaffold.
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<String> _skills = [
    'Select a Skill',
    'Mathematics',
    'Physics',
    'English',
    'History',
    'Programming',
    'Data Science',
  ];
  final List<String> _timeSlots = [
    'Select a Time Slot',
    '9:00 am - 12:00 pm',
    '1:00 pm - 4:00 pm',
    '6:00 pm - 9:00 pm',
  ];

  String? _selectedPreferredSkill;
  String? _selectedTimeSlot;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _bookSession() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedPreferredSkill == null ||
        _selectedTimeSlot == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please fill all the booking details')),
      );
      return;
    }

    // Assuming a user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to book a session'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'skill': _selectedPreferredSkill,
        'timeSlot': _selectedTimeSlot,
        'contact': _phoneController.text.trim(),
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Session booked successfully!')),
      );

      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      setState(() {
        _selectedPreferredSkill = null;
        _selectedTimeSlot = null;
      });
    } catch (e) {
      print('Error booking session: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to book session. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Mentor'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Booking Details'),
          const SizedBox(height: 16),
          _buildBookingForm(),
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
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Your Name'),
        ),
        const SizedBox(height: 16),
        _buildDropdown(_skills, _selectedPreferredSkill, 'Preferred Skill', (
          value,
        ) {
          setState(() {
            _selectedPreferredSkill = value;
          });
        }),
        const SizedBox(height: 16),
        _buildDropdown(_timeSlots, _selectedTimeSlot, 'Select a Time Slot', (
          value,
        ) {
          setState(() {
            _selectedTimeSlot = value;
          });
        }),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Contact Email'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Phone Number'),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _bookSession,
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

  Widget _buildDropdown(
    List<String> items,
    String? selectedValue,
    String hint,
    ValueChanged<String?> onChanged,
  ) {
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
          child: Text(
            value,
            style: value == hint ? TextStyle(color: Colors.grey.shade500) : null,
          ),
        );
      }).toList(),
    );
  }
}
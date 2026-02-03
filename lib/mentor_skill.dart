import 'package:flutter/material.dart';
import 'package:studybuddy/crtacc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edit Skills UI',
      theme: ThemeData(
        // A slightly off-white background color to match the image
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Inter', // A clean, modern font
      ),
      home: const EditSkillsScreen(),
    );
  }
}

class EditSkillsScreen extends StatefulWidget {
  const EditSkillsScreen({super.key});
  @override
  State<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends State<EditSkillsScreen> {
  // Controller to manage the text input for adding new skills
  final _skillController = TextEditingController();

  // A list to hold the user's skills. Pre-populated for demonstration.
  final List<String> _skills = [
    'Data Analysis',
    'Machine Learning',
    'Python',
    'SQL',
    'Communication',
  ];

  // The currently selected index for the bottom navigation bar
  int _bottomNavIndex = 1; // 'Profile' is selected as per the image

  // Function to add a new skill to the list
  void _addSkill() {
    final newSkill = _skillController.text.trim();
    // Add only if the input is not empty and not already in the list
    if (newSkill.isNotEmpty && !_skills.contains(newSkill)) {
      setState(() {
        _skills.add(newSkill);
        _skillController.clear(); // Clear the text field after adding
      });
    }
  }

  // Function to remove a skill from the list
  void _removeSkill(String skillToRemove) {
    setState(() {
      _skills.remove(skillToRemove);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define colors from the image for easy reuse
    const primaryColor = Color(0xFF3498DB);
    const chipBackgroundColor = Color(0xFFE0F7FA);
    const chipTextColor = Color(0xFF3498DB);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
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
        title: const Text(
          'Edit Skills',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section for displaying existing skills
            const Text(
              'Your Skills',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children:
                  _skills.map((skill) {
                    return InputChip(
                      label: Text(skill),
                      labelStyle: const TextStyle(
                        color: Color(0xFF3498DB),
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: chipBackgroundColor,
                      onDeleted: () => _removeSkill(skill),
                      deleteIconColor: Color(0xFF3498DB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide.none,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 40),

            // Section for adding a new skill
            const Text(
              'Add New Skill',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Project Management',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xFF3498DB)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 58, // Match text field height
                  child: ElevatedButton(
                    onPressed: _addSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3498DB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const Spacer(), // Pushes the 'Save' button to the bottom
            // The 'Save Changes' button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement save functionality
                  print('Changes Saved!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3498DB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
            bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF3498DB),
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),

    );
  }
}

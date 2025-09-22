import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:studybuddy/Monboard.dart';
import 'package:studybuddy/firebase_options.dart';
import 'package:studybuddy/main_screen.dart';
import 'package:studybuddy/login_page.dart';
import 'package:studybuddy/mentor_list.dart';
import 'package:studybuddy/mentor_skill.dart';
import 'package:studybuddy/mentorpage.dart';
import 'package:studybuddy/onboar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthGate());
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      return userDoc.data();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return LoginPage();
        }

        final user = snapshot.data!;

        // User logged in, fetch Firestore data
        return FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnapshot.data;

            if (userData == null) {
              // No user data found
              return LoginPage();
            }

            final role = userData['role'] as String?;
            final completedOnboarding =
                userData['completedOnboarding'] as bool? ?? false;

            debugPrint(
              "✅ AuthGate role: $role, completedOnboarding: $completedOnboarding",
            );

            // If onboarding not completed, show Onboarding screen

            // Navigate based on role
            if (role == 'student') {
              if (!completedOnboarding) {
                return OnboardingPage(
                  uid: user.uid,
                ); // pass uid to update later
              }
              return const HomeScreen();
            } else if (role == 'mentor') {
              if (!completedOnboarding) {
                return MOnboardingPage(
                  uid: user.uid,
                ); // pass uid to update later
              }
              return MentorsListPage();
            } else {
              // Role not set
              return LoginPage();
            }
          },
        );
      },
    );
  }
}

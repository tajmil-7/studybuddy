// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/firebase_options.dart';
import 'package:studybuddy/login_page.dart';
import 'package:studybuddy/main_wrapper.dart'; // Import the new wrapper
import 'package:studybuddy/Monboard.dart';
import 'package:studybuddy/onboar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = authSnapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
            final role = userData?['role'] as String?;
            final completedOnboarding =
                userData?['completedOnboarding'] as bool? ?? false;

            if (role == 'student' && !completedOnboarding) {
              return OnboardingPage(uid: user.uid);
            }
            if (role == 'mentor' && !completedOnboarding) {
              return MOnboardingPage(uid: user.uid);
            }

            if (role != null && completedOnboarding) {
              return MainWrapper(userRole: role, userUid: user.uid);
            }

            return const LoginPage();
          },
        );
      },
    );
  }
}

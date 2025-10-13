import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuk_meal/screens/onboarding/OnboardingPage.dart';
import 'package:tuk_meal/screens/main/MainScreen.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TUK eMeal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: "Roboto",
      ),
      home: const AuthRedirect(),
    );
  }
}

class AuthRedirect extends StatelessWidget {
  const AuthRedirect({super.key});

  Future<Widget> _getHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    // If user is logged in and has token, go to MainPage
    if (isLoggedIn && token != null) {
      return MainPage(token: token);
    }
    
    // Otherwise, show onboarding
    return const OnboardingPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getHomePage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return snapshot.data ?? const OnboardingPage();
      },
    );
  }
}
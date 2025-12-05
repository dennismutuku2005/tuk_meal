import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tuk_meal/services/shared_prefs_service.dart';
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
    final isLoggedIn = await SharedPrefsService.isLoggedIn();
    final token = await SharedPrefsService.getToken();
    final userData = await SharedPrefsService.getUserData();
    
    debugPrint('Auth check - isLoggedIn: $isLoggedIn');
    debugPrint('Auth check - token: $token');
    debugPrint('Auth check - userData: $userData');
    
    // Check all conditions based on SharedPrefsService logic
    if (isLoggedIn && token != null && token.isNotEmpty && userData != null) {
      // Check if userData has at least mobile number or essential fields
      final hasMobileNumber = userData['mobile'] != null;
      final hasEssentialFields = userData.containsKey('id') || 
                                 userData.containsKey('user_id');
      
      if (hasMobileNumber || hasEssentialFields) {
        debugPrint('User authenticated successfully with mobile: ${userData['mobile']}');
        return MainPage(token: token);
      } else {
        debugPrint('User data missing essential fields: ${userData.keys.toList()}');
        // Clear invalid data
        await SharedPrefsService.clearAllData();
      }
    } else {
      debugPrint('Authentication failed - missing one of: isLoggedIn=$isLoggedIn, token=$token, userData=$userData');
      
      // If partially logged in but missing data, clear everything
      if (isLoggedIn && (token == null || userData == null)) {
        await SharedPrefsService.clearAllData();
      }
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
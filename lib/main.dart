import 'package:flutter/material.dart';
import 'package:tuk_meal/screens/onboarding/OnboardingPage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // removes the debug banner
      title: 'TUK eMeal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: "Roboto",
      ),
      home: const OnboardingPage(),
    );
  }
}

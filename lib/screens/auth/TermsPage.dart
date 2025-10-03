// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndPolicyPage extends StatelessWidget {
  const TermsAndPolicyPage({super.key});

  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Terms & Privacy Policy",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Introduction",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Welcome to our application. By accessing or using our services, you agree "
              "to be bound by these Terms and our Privacy Policy. Please read them carefully. "
              "If you do not agree with any part of these terms, you must not use the app.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              "2. User Responsibilities",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "You agree to use the app only for lawful purposes and in accordance with these Terms. "
              "You are responsible for maintaining the confidentiality of your account credentials, "
              "and you must notify us immediately if you suspect any unauthorized access to your account. "
              "You must not misuse the app by introducing viruses, trojans, or other harmful material.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              "3. Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "We value your privacy. The information you provide will only be used to deliver "
              "and improve our services. We do not sell your personal data to third parties. "
              "We may share information with trusted partners who assist us in operating our services, "
              "subject to strict confidentiality agreements. For more details, please read our extended "
              "Privacy Policy.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              "4. Data Collection",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "We may collect personal information such as your name, mobile number, and account activity. "
              "This information helps us provide personalized services and improve the overall user experience. "
              "Usage data may also be collected, including log files, device information, and app performance metrics. "
              "We take appropriate security measures to protect your data from unauthorized access.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              "5. Limitation of Liability",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "We make no guarantees that the app will be error-free, uninterrupted, or that defects will be corrected. "
              "We shall not be liable for any direct, indirect, incidental, or consequential damages arising from the use "
              "of our services, including but not limited to data loss, unauthorized access, or technical malfunctions.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              "6. Changes to These Terms",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "We reserve the right to modify these Terms and the Privacy Policy at any time. Any changes will be communicated "
              "through the app or via the contact details you have provided. Continued use of the app after changes means you "
              "accept the new terms.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              "7. Contact Us",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "If you have any questions regarding these Terms or our Privacy Policy, please contact us at "
              "support@example.com or through the in-app support feature.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 40),

            Center(
              child: InkWell(
                onTap: () {
                  _launchURL("https://quickzingo.com");
                },
                child: Text(
                  "Read Full Terms & Privacy Policy Here",
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

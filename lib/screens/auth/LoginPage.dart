import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    // Configure status bar appearance
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {

        //
        final baseUrl = dotenv.env['API_BASE_URL'] ?? "";
        final url = Uri.parse("$baseUrl/register.php");
        // Prepare the request
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'mobile_number': _mobileController.text,
            'password': _passwordController.text,
          }),
        ).timeout(const Duration(seconds: 30));

        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          // Save user data to SharedPreferences
          await _saveUserData(data);
          
          // Navigate to home page and clear all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: primaryGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(data['user']));
    await prefs.setString('auth_token', data['token']);
    await prefs.setBool('is_logged_in', true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            top: true,
            child: Column(
              children: [
                // Custom back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                    ),
                  ),
                ),
                
                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Header section
                          Center(
                            child: Column(
                              children: [
                                // Logo
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: primaryGreen,
                                          borderRadius: BorderRadius.circular(70),
                                        ),
                                        child: const Icon(
                                          Icons.restaurant,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 24),

                                const Text(
                                  "Welcome Back!",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: -0.5,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Sign in with your mobile number",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Mobile number field
                          Text(
                            "Mobile Number",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: "Enter your mobile number",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(
                                Icons.phone_android_outlined,
                                color: Colors.grey[400],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: primaryGreen,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (!RegExp(r'^(\+254|0)[7][0-9]{8}$').hasMatch(value.replaceAll(' ', ''))) {
                                return 'Please enter a valid Kenyan mobile number';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Password field
                          Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[400],
                              ),
                              suffixIcon: IconButton(
                                onPressed: _isLoading ? null : () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[400],
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: primaryGreen,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading ? null : () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => const ForgotPasswordPage(),
                                //   ),
                                // );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: primaryGreen.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider with "or"
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[300])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "or",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[300])),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Sign up link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading ? null : () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (_) => const RegisterPage(),
                                    //   ),
                                    // );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Loading overlay - prevents interaction when loading
        if (_isLoading)
          ModalBarrier(
            color: Colors.black.withOpacity(0.5),
            dismissible: false,
          ),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF0F7B0F),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Color(0xFF0F7B0F),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to TUK Meal!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You have successfully logged in',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
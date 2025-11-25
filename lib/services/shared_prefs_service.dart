import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  // Save token - now saves mobile number as token
  static Future<void> saveToken(String mobileNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, mobileNumber);
  }

  // Get token - now returns mobile number instead of token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    // First try to get mobile number from user data
    final userData = await getUserData();
    if (userData != null && userData['mobile'] != null) {
      return userData['mobile'].toString();
    }
    
    // Fallback to the stored token (which is now mobile number)
    return prefs.getString(_tokenKey);
  }

  // Set login status
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear all data (logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_isLoggedInKey);
  }

  // Helper method to get mobile number directly
  static Future<String?> getMobileNumber() async {
    return await getToken(); // Since getToken now returns mobile number
  }
}
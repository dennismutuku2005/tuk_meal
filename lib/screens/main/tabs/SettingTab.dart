import 'package:flutter/material.dart';
import 'package:tuk_meal/screens/onboarding/OnboardingPage.dart';
import 'package:tuk_meal/services/shared_prefs_service.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const SettingsPage({super.key, required this.userData});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _autoLoginEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'KES';
  String _selectedTheme = 'System default';
  
  String? _firstName;
  String? _lastName;
  String? _userMobile;

  final List<String> _languages = ['English', 'Kiswahili', 'French', 'Spanish'];
  final List<String> _currencies = ['KES', 'USD', 'EUR', 'GBP'];
  final List<String> _themes = ['System default', 'Light', 'Dark'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await SharedPrefsService.getUserData();
    if (userData != null) {
      setState(() {
        _firstName = userData['first_name']?.toString() ?? 'User 1';
        _lastName = userData['last_name']?.toString() ?? '';
        _userMobile = userData['mobile']?.toString() ?? 
                     userData['mobile_number']?.toString() ?? 
                     'No mobile';
      });
    }
  }

  // Show custom beta message modal
  void _showBetaMessage(String featureName) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.new_releases,
                    size: 30,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Beta Feature',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Message
                Text(
                  '$featureName is not available in the beta version.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Got It',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _performLogout();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  // Perform logout
  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Clear all user data from SharedPreferences
      await SharedPrefsService.clearAllData();
      
      // Close the loading dialog
      Navigator.pop(context);
      
      // Navigate to OnboardingPage and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (route) => false,
      );
      
    } catch (e) {
      // Close the loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // User profile section (simplified - no DP, no edit button)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name icon and text
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (fullName.isNotEmpty)
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          if (fullName.isEmpty)
                            const Text(
                              'User',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            _userMobile ?? 'No mobile number',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Preferences section
          _buildSectionHeader('Preferences'),
          _buildPreferenceCard(),
          
          // Notification settings
          _buildSectionHeader('Notifications'),
          _buildNotificationCard(),
          
          // Security settings
          _buildSectionHeader('Security'),
          _buildSecurityCard(),
          
          // App settings
          _buildSectionHeader('App Settings'),
          _buildAppSettingsCard(),
          
          // Support section
          _buildSectionHeader('Support'),
          _buildSupportCard(),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _showLogoutConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildPreferenceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Language preference
          ListTile(
            leading: Icon(Icons.language, color: primaryGreen),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              onChanged: null, // Disabled in beta
              items: _languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            onTap: () => _showBetaMessage('Language Settings'),
          ),
          const Divider(height: 1),
          
          // Currency preference
          ListTile(
            leading: Icon(Icons.currency_exchange, color: primaryGreen),
            title: const Text('Currency'),
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              underline: const SizedBox(),
              onChanged: null, // Disabled in beta
              items: _currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            onTap: () => _showBetaMessage('Currency Settings'),
          ),
          const Divider(height: 1),
          
          // Theme preference
          ListTile(
            leading: Icon(Icons.color_lens, color: primaryGreen),
            title: const Text('Theme'),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              underline: const SizedBox(),
              onChanged: null, // Disabled in beta
              items: _themes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            onTap: () => _showBetaMessage('Theme Settings'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Notifications toggle
          ListTile(
            leading: Icon(Icons.notifications, color: primaryGreen),
            title: const Text('Enable Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Notification Settings'),
          ),
          const Divider(height: 1),
          
          // Order updates
          ListTile(
            leading: Icon(Icons.fastfood, color: primaryGreen),
            title: const Text('Order Updates'),
            trailing: Switch(
              value: true,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Order Update Settings'),
          ),
          const Divider(height: 1),
          
          // Promotional notifications
          ListTile(
            leading: Icon(Icons.local_offer, color: primaryGreen),
            title: const Text('Promotions & Offers'),
            trailing: Switch(
              value: true,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Promotion Settings'),
          ),
          const Divider(height: 1),
          
          // Payment notifications
          ListTile(
            leading: Icon(Icons.payment, color: primaryGreen),
            title: const Text('Payment Notifications'),
            trailing: Switch(
              value: true,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Payment Notification Settings'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSecurityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Biometric authentication
          ListTile(
            leading: Icon(Icons.fingerprint, color: primaryGreen),
            title: const Text('Biometric Login'),
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Biometric Login'),
          ),
          const Divider(height: 1),
          
          // Auto login
          ListTile(
            leading: Icon(Icons.login, color: primaryGreen),
            title: const Text('Auto Login'),
            trailing: Switch(
              value: _autoLoginEnabled,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Auto Login'),
          ),
          const Divider(height: 1),
          
          // Change password
          ListTile(
            leading: Icon(Icons.lock, color: primaryGreen),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Password Change'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // App version
          ListTile(
            leading: Icon(Icons.info, color: primaryGreen),
            title: const Text('App Version'),
            trailing: const Text('1.0.0 (Beta)'),
          ),
          const Divider(height: 1),
          
          // Clear cache
          ListTile(
            leading: Icon(Icons.cached, color: primaryGreen),
            title: const Text('Clear Cache'),
            trailing: const Text('12.5 MB'),
            onTap: () => _showBetaMessage('Cache Clearing'),
          ),
          const Divider(height: 1),
          
          // Data usage
          ListTile(
            leading: Icon(Icons.data_usage, color: primaryGreen),
            title: const Text('Data Usage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Data Usage Statistics'),
          ),
          const Divider(height: 1),
          
          // Terms of service
          ListTile(
            leading: Icon(Icons.description, color: primaryGreen),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Terms of Service'),
          ),
          const Divider(height: 1),
          
          // Privacy policy
          ListTile(
            leading: Icon(Icons.privacy_tip, color: primaryGreen),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Privacy Policy'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSupportCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Help center
          ListTile(
            leading: Icon(Icons.help, color: primaryGreen),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Help Center'),
          ),
          const Divider(height: 1),
          
          // Contact support
          ListTile(
            leading: Icon(Icons.support_agent, color: primaryGreen),
            title: const Text('Contact Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Contact Support'),
          ),
          const Divider(height: 1),
          
          // Report a problem
          ListTile(
            leading: Icon(Icons.report_problem, color: primaryGreen),
            title: const Text('Report a Problem'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Problem Reporting'),
          ),
          const Divider(height: 1),
          
          // Rate the app
          ListTile(
            leading: Icon(Icons.star, color: primaryGreen),
            title: const Text('Rate the App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('App Rating'),
          ),
        ],
      ),
    );
  }
}
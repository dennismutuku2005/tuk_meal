import 'package:flutter/material.dart';

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

  final List<String> _languages = ['English', 'Kiswahili', 'French', 'Spanish'];
  final List<String> _currencies = ['KES', 'USD', 'EUR', 'GBP'];
  final List<String> _themes = ['System default', 'Light', 'Dark'];

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
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
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
                SizedBox(height: 16),
                
                // Title
                Text(
                  'Beta Feature',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                
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
                SizedBox(height: 20),
                
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back button
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24),
        children: [
          // User profile section
          _buildProfileSection(),
          
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
              onPressed: () => _showBetaMessage('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: primaryGreen.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 32,
              color: primaryGreen,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userData['name'] ?? 'User Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.userData['email'] ?? 'user@example.com',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.userData['phone'] ?? '+254 712 345 678',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showBetaMessage('Profile Editing'),
            icon: Icon(Icons.edit, color: primaryGreen),
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
  
  Widget _buildPreferenceCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Language preference
          ListTile(
            leading: Icon(Icons.language, color: primaryGreen),
            title: Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: SizedBox(),
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
          Divider(height: 1),
          
          // Currency preference
          ListTile(
            leading: Icon(Icons.currency_exchange, color: primaryGreen),
            title: Text('Currency'),
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              underline: SizedBox(),
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
          Divider(height: 1),
          
          // Theme preference
          ListTile(
            leading: Icon(Icons.color_lens, color: primaryGreen),
            title: Text('Theme'),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              underline: SizedBox(),
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Notifications toggle
          ListTile(
            leading: Icon(Icons.notifications, color: primaryGreen),
            title: Text('Enable Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Notification Settings'),
          ),
          Divider(height: 1),
          
          // Order updates
          ListTile(
            leading: Icon(Icons.fastfood, color: primaryGreen),
            title: Text('Order Updates'),
            trailing: Switch(
              value: true,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Order Update Settings'),
          ),
          Divider(height: 1),
          
          // Promotional notifications
          ListTile(
            leading: Icon(Icons.local_offer, color: primaryGreen),
            title: Text('Promotions & Offers'),
            trailing: Switch(
              value: true,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Promotion Settings'),
          ),
          Divider(height: 1),
          
          // Payment notifications
          ListTile(
            leading: Icon(Icons.payment, color: primaryGreen),
            title: Text('Payment Notifications'),
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Biometric authentication
          ListTile(
            leading: Icon(Icons.fingerprint, color: primaryGreen),
            title: Text('Biometric Login'),
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Biometric Login'),
          ),
          Divider(height: 1),
          
          // Auto login
          ListTile(
            leading: Icon(Icons.login, color: primaryGreen),
            title: Text('Auto Login'),
            trailing: Switch(
              value: _autoLoginEnabled,
              onChanged: null, // Disabled in beta
            ),
            onTap: () => _showBetaMessage('Auto Login'),
          ),
          Divider(height: 1),
          
          // Change password
          ListTile(
            leading: Icon(Icons.lock, color: primaryGreen),
            title: Text('Change Password'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Password Change'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppSettingsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // App version
          ListTile(
            leading: Icon(Icons.info, color: primaryGreen),
            title: Text('App Version'),
            trailing: Text('1.0.0 (Beta)'),
          ),
          Divider(height: 1),
          
          // Clear cache
          ListTile(
            leading: Icon(Icons.cached, color: primaryGreen),
            title: Text('Clear Cache'),
            trailing: Text('12.5 MB'),
            onTap: () => _showBetaMessage('Cache Clearing'),
          ),
          Divider(height: 1),
          
          // Data usage
          ListTile(
            leading: Icon(Icons.data_usage, color: primaryGreen),
            title: Text('Data Usage'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Data Usage Statistics'),
          ),
          Divider(height: 1),
          
          // Terms of service
          ListTile(
            leading: Icon(Icons.description, color: primaryGreen),
            title: Text('Terms of Service'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Terms of Service'),
          ),
          Divider(height: 1),
          
          // Privacy policy
          ListTile(
            leading: Icon(Icons.privacy_tip, color: primaryGreen),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Privacy Policy'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSupportCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Help center
          ListTile(
            leading: Icon(Icons.help, color: primaryGreen),
            title: Text('Help Center'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Help Center'),
          ),
          Divider(height: 1),
          
          // Contact support
          ListTile(
            leading: Icon(Icons.support_agent, color: primaryGreen),
            title: Text('Contact Support'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Contact Support'),
          ),
          Divider(height: 1),
          
          // Report a problem
          ListTile(
            leading: Icon(Icons.report_problem, color: primaryGreen),
            title: Text('Report a Problem'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('Problem Reporting'),
          ),
          Divider(height: 1),
          
          // Rate the app
          ListTile(
            leading: Icon(Icons.star, color: primaryGreen),
            title: Text('Rate the App'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showBetaMessage('App Rating'),
          ),
        ],
      ),
    );
  }
}
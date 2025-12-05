import 'package:flutter/material.dart';
import 'dart:math';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required List<Map<String, dynamic>> cartItems, required double totalPrice});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Hardcoded dummy cart data (same as CartPage)
  final List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Chapo Beans',
      'price': 140.0, // Total price (70 * 2)
      'quantity': 2,
      'image': 'https://images.unsplash.com/photo-1603048698243-98e7e3b537da',
    },
    {
      'name': 'Mandazi Chai',
      'price': 50.0, // Total price (50 * 1)
      'quantity': 1,
      'image': 'https://images.unsplash.com/photo-1517248135467-3c1094f5a4b1',
    },
  ];

  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = false;

  // Calculate total cart price
  double _calculateTotalCartPrice() {
    return cartItems.fold(0.0, (sum, item) => sum + (item['price'] as num).toDouble());
  }

  // Validate Kenyan M-Pesa phone number (+254 or 07/01 formats)
  void _validatePhoneNumber(String value) {
    final phoneRegex = RegExp(r'^(?:\+254|07|01)\d{8}$');
    setState(() {
      _isPhoneValid = phoneRegex.hasMatch(value);
    });
  }

  // Simulate M-Pesa payment
  void _simulatePayment() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: primaryGreen),
      ),
    );

    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Close loading dialog
    Navigator.pop(context);

    // Generate random receipt number
    final receiptNumber = 'MPESA${Random().nextInt(1000000000).toString().padLeft(10, '0')}';

    // Show receipt number
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Payment Successful',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
        ),
        content: Text(
          'Thank you for your payment!\nReceipt Number: $receiptNumber',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, ModalRoute.withName('/')); // Return to HomeTab
            },
            child: Text(
              'Done',
              style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Checkout',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),

          // Order summary
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  ...cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item['name']} (x${item['quantity']})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'KES ${(item['price'] as num).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      )),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'KES ${_calculateTotalCartPrice().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // M-Pesa phone number input
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'M-Pesa Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'e.g., +254712345678 or 0712345678',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryGreen),
                      ),
                      errorText: _isPhoneValid || _phoneController.text.isEmpty
                          ? null
                          : 'Enter a valid Kenyan phone number',
                    ),
                    onChanged: _validatePhoneNumber,
                  ),
                ],
              ),
            ),
          ),

          // Pay Now button
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPhoneValid ? _simulatePayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Pay Now',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}
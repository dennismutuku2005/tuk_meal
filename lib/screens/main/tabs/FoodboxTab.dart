import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tuk_meal/services/shared_prefs_service.dart';

class FoodBoxTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  const FoodBoxTab({super.key, required this.userData});

  @override
  State<FoodBoxTab> createState() => _FoodBoxTabState();
}

class _FoodBoxTabState extends State<FoodBoxTab> {
  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  int _selectedTab = 0; // 0 for Active, 1 for History
  List<Map<String, dynamic>> _activeOrders = [];
  List<Map<String, dynamic>> _pastReceipts = [];
  
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await SharedPrefsService.getToken();
      if (token == null) {
        throw Exception('Please login to view orders');
      }

      final response = await http.get(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/foodbox.php')
          .replace(queryParameters: {
            'mobile_number': token,
            'action': 'get_orders'
          }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          final responseData = data['data'];
          
          // Process active orders
          final List<Map<String, dynamic>> activeOrders = [];
          final activeOrdersData = (responseData['active_orders'] as List).cast<Map<String, dynamic>>();
          for (var order in activeOrdersData) {
            activeOrders.add({
              'id': 'ORD-${order['id'].toString().padLeft(6, '0')}',
              'date': DateTime.parse(order['created_at'].toString()),
              'items': [],
              'total': (order['total'] is String) ? double.parse(order['total']) : (order['total'] as num).toDouble(),
              'status': _capitalizeFirstLetter(order['status'].toString()),
              'canteen': 'TUK Canteen',
              'receiptCode': order['receipt_code'].toString(),
              'qrData': order['qr_data']?.toString() ?? '',
              'order_id': (order['id'] is String) ? int.parse(order['id']) : order['id'] as int,
              'item_count': (order['item_count'] is String) ? int.parse(order['item_count']) : order['item_count'] as int,
              'type': 'active'
            });
          }

          // Process past receipts
          final List<Map<String, dynamic>> pastReceipts = [];
          final pastReceiptsData = (responseData['past_receipts'] as List).cast<Map<String, dynamic>>();
          for (var receipt in pastReceiptsData) {
            pastReceipts.add({
              'id': 'REC-${receipt['id'].toString().padLeft(6, '0')}',
              'date': DateTime.parse(receipt['created_at'].toString()),
              'items': [],
              'total': (receipt['total'] is String) ? double.parse(receipt['total']) : (receipt['total'] as num).toDouble(),
              'status': _capitalizeFirstLetter(receipt['status'].toString()),
              'canteen': 'TUK Canteen',
              'receiptCode': receipt['receipt_code'].toString(),
              'qrData': receipt['qr_data']?.toString() ?? '',
              'order_id': (receipt['id'] is String) ? int.parse(receipt['id']) : receipt['id'] as int,
              'item_count': (receipt['item_count'] is String) ? int.parse(receipt['item_count']) : receipt['item_count'] as int,
              'type': 'completed'
            });
          }

          setState(() {
            _activeOrders = activeOrders;
            _pastReceipts = pastReceipts;
            _isLoading = false;
          });
        } else {
          throw Exception(data['message']?.toString() ?? 'Failed to load orders');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _loadOrderDetails(int orderId) async {
    try {
      final token = await SharedPrefsService.getToken();
      if (token == null) {
        throw Exception('Please login to view order details');
      }

      final response = await http.get(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/foodbox.php')
          .replace(queryParameters: {
            'mobile_number': token,
            'action': 'get_order_details',
            'order_id': orderId.toString()
          }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message']?.toString() ?? 'Failed to load order details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadData();
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Food Box",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: _isRefreshing ? primaryGreen : Colors.black87,
            ),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F7B0F)),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading orders',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: primaryGreen,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Tab selector only (Spending Summary removed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedTab = 0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedTab == 0 ? primaryGreen : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Active Orders",
                                          style: TextStyle(
                                            color: _selectedTab == 0 ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedTab = 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedTab == 1 ? primaryGreen : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Past Receipts",
                                          style: TextStyle(
                                            color: _selectedTab == 1 ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Orders/Receipts list based on selected tab
                        _selectedTab == 0
                            ? _buildActiveOrdersList()
                            : _buildPastReceiptsList(),

                        // Add some bottom padding
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildActiveOrdersList() {
    if (_activeOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No active orders",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your upcoming orders will appear here",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _activeOrders.map((order) {
        return _buildOrderCard(order, true);
      }).toList(),
    );
  }

  Widget _buildPastReceiptsList() {
    if (_pastReceipts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.receipt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No past receipts",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your purchase history will appear here",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _pastReceipts.map((receipt) {
        return _buildOrderCard(receipt, false);
      }).toList(),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isActive) {
    return GestureDetector(
      onTap: () => _showOrderDetails(order, isActive),
      onLongPress: () => _showReceiptCodeInfo(order),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order["id"].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? primaryGreen.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order["status"].toString(),
                    style: TextStyle(
                      color: isActive ? primaryGreen : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('EEE, MMM d • h:mm a').format(order["date"] as DateTime),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "TUK Canteen",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${order["item_count"]} item${(order["item_count"] as int) > 1 ? 's' : ''}",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "KES ${(order["total"] as num).toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F7B0F),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isActive) ...[
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code, size: 16, color: Color(0xFF0F7B0F)),
                  const SizedBox(width: 8),
                  Text(
                    "Receipt Code: ${order["receiptCode"]}",
                    style: const TextStyle(
                      color: Color(0xFF0F7B0F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showOrderDetails(Map<String, dynamic> order, bool isActive) async {
    try {
      final orderDetails = await _loadOrderDetails(order['order_id'] as int);
      final items = (orderDetails['items'] as List).cast<Map<String, dynamic>>();
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order["id"].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? primaryGreen.withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order["status"].toString(),
                        style: TextStyle(
                          color: isActive ? primaryGreen : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEE, MMM d, yyyy • h:mm a').format(order["date"] as DateTime),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "TUK Canteen",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "ORDER ITEMS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: items.map<Widget>((item) {
                    final price = (item['price'] is String) ? double.parse(item['price']) : (item['price'] as num).toDouble();
                    final quantity = (item['quantity'] is String) ? int.parse(item['quantity']) : item['quantity'] as int;
                    final total = price * quantity;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item['quantity']}x ${item['name']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            "KES ${total.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "KES ${order["total"]}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0F7B0F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isActive) ...[
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.qr_code, size: 64, color: Color(0xFF0F7B0F)),
                              const SizedBox(height: 12),
                              const Text(
                                "Receipt Code",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order["receiptCode"].toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Color(0xFF0F7B0F),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Show this code at the canteen",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Long press on receipt for more options",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load order details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReceiptCodeInfo(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Receipt Code Info"),
          content: Text(
            "Your receipt code ${order["receiptCode"]} has been sent to your phone via SMS and WhatsApp. "
            "You can present this code at the canteen to collect your order.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(color: Color(0xFF0F7B0F)),
              ),
            ),
          ],
        );
      },
    );
  }
}
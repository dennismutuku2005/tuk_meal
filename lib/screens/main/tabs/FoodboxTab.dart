import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final List<Map<String, dynamic>> _activeOrders = [];
  final List<Map<String, dynamic>> _pastReceipts = [];

  double _averageDailySpend = 0.0;
  double _totalSpendThisWeek = 0.0;
  double _totalSpendThisMonth = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Simulate loading data with dummy data for now
    setState(() {
      // Active orders (meals to be consumed)
      _activeOrders.addAll([
        {
          "id": "ORD-789012",
          "date": DateTime.now().add(Duration(hours: 2)),
          "items": [
            {"name": "Ugali Nyama", "price": 120, "quantity": 1},
            {"name": "Fruit Salad", "price": 60, "quantity": 1},
          ],
          "total": 180,
          "status": "Preparing",
          "canteen": "Main Campus Canteen",
          "receiptCode": "5A8B2",
          "qrData": "ORD-789012-5A8B2-${DateTime.now().millisecondsSinceEpoch}",
        },
        {
          "id": "ORD-345678",
          "date": DateTime.now().add(Duration(hours: 5)),
          "items": [
            {"name": "Rice Ndengu", "price": 90, "quantity": 1},
            {"name": "Juice", "price": 40, "quantity": 1},
          ],
          "total": 130,
          "status": "Ordered",
          "canteen": "North Campus Canteen",
          "receiptCode": "3F9C1",
          "qrData": "ORD-345678-3F9C1-${DateTime.now().millisecondsSinceEpoch}",
        },
      ]);

      // Past receipts
      _pastReceipts.addAll([
        {
          "id": "REC-123456",
          "date": DateTime.now().subtract(Duration(days: 1)),
          "items": [
            {"name": "Chapo Beans", "price": 70, "quantity": 2},
            {"name": "Tea", "price": 30, "quantity": 1},
          ],
          "total": 170,
          "status": "Completed",
          "canteen": "Main Campus Canteen",
          "receiptCode": "7D4E2",
          "qrData": "REC-123456-7D4E2-${DateTime.now().millisecondsSinceEpoch}",
        },
        {
          "id": "REC-234567",
          "date": DateTime.now().subtract(Duration(days: 2)),
          "items": [
            {"name": "Pilau Beef", "price": 150, "quantity": 1},
          ],
          "total": 150,
          "status": "Completed",
          "canteen": "South Campus Canteen",
          "receiptCode": "9G1H5",
          "qrData": "REC-234567-9G1H5-${DateTime.now().millisecondsSinceEpoch}",
        },
        {
          "id": "REC-345678",
          "date": DateTime.now().subtract(Duration(days: 3)),
          "items": [
            {"name": "Vegetable Curry", "price": 85, "quantity": 1},
            {"name": "Chapati", "price": 30, "quantity": 2},
          ],
          "total": 145,
          "status": "Completed",
          "canteen": "Main Campus Canteen",
          "receiptCode": "2J8K3",
          "qrData": "REC-345678-2J8K3-${DateTime.now().millisecondsSinceEpoch}",
        },
        {
          "id": "REC-456789",
          "date": DateTime.now().subtract(Duration(days: 4)),
          "items": [
            {"name": "Mandazi Chai", "price": 50, "quantity": 1},
            {"name": "Fruit Salad", "price": 60, "quantity": 1},
          ],
          "total": 110,
          "status": "Completed",
          "canteen": "North Campus Canteen",
          "receiptCode": "6L4M9",
          "qrData": "REC-456789-6L4M9-${DateTime.now().millisecondsSinceEpoch}",
        },
        {
          "id": "REC-567890",
          "date": DateTime.now().subtract(Duration(days: 5)),
          "items": [
            {"name": "Chicken Stew", "price": 130, "quantity": 1},
            {"name": "Ugali", "price": 40, "quantity": 1},
          ],
          "total": 170,
          "status": "Completed",
          "canteen": "Main Campus Canteen",
          "receiptCode": "1N5O7",
          "qrData": "REC-567890-1N5O7-${DateTime.now().millisecondsSinceEpoch}",
        },
      ]);

      // Calculate spending statistics
      _calculateSpendingStats();
    });
  }

  void _calculateSpendingStats() {
    // Calculate average daily spend (last 7 days)
    double weeklyTotal = 0;
    double monthlyTotal = 0;
    int days = 0;
    DateTime now = DateTime.now();

    for (var receipt in _pastReceipts) {
      if (now.difference(receipt["date"]).inDays <= 7) {
        weeklyTotal += receipt["total"];
        days++;
      }

      if (now.difference(receipt["date"]).inDays <= 30) {
        monthlyTotal += receipt["total"];
      }
    }

    _totalSpendThisWeek = weeklyTotal;
    _totalSpendThisMonth = monthlyTotal;
    _averageDailySpend = days > 0 ? weeklyTotal / days : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Food Box",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Spending summary card
            _buildSpendingSummary(),

            // Tab selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          padding: EdgeInsets.symmetric(vertical: 12),
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
                          padding: EdgeInsets.symmetric(vertical: 12),
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
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingSummary() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spending Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          // Spending stats in a grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Daily Average",
                  "KES ${_averageDailySpend.toStringAsFixed(0)}",
                  Icons.today,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "This Week",
                  "KES ${_totalSpendThisWeek.toStringAsFixed(0)}",
                  Icons.calendar_view_week,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildStatCard(
            "This Month",
            "KES ${_totalSpendThisMonth.toStringAsFixed(0)}",
            Icons.calendar_month,
            fullWidth: true,
          ),

          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 8),

          // Recent spending list
          Text(
            "Recent Spending",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),

          // Show last 3 receipts in summary
          Column(
            children: _pastReceipts.take(3).map((receipt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('EEE, MMM d').format(receipt["date"]),
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      "KES ${receipt["total"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryGreen),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersList() {
    if (_activeOrders.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              "No active orders",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
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
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.receipt, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              "No past receipts",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
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
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order["id"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? primaryGreen.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order["status"],
                    style: TextStyle(
                      color: isActive ? primaryGreen : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              DateFormat('EEE, MMM d • h:mm a').format(order["date"]),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Text(
              order["canteen"],
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${order["items"].length} item${order["items"].length > 1 ? 's' : ''}",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "KES ${order["total"]}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (isActive) ...[
              Divider(height: 1),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 16, color: primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    "Receipt Code: ${order["receiptCode"]}",
                    style: TextStyle(
                      color: primaryGreen,
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

  void _showOrderDetails(Map<String, dynamic> order, bool isActive) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.all(16),
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order["id"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? primaryGreen.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order["status"],
                      style: TextStyle(
                        color: isActive ? primaryGreen : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                DateFormat('EEE, MMM d, yyyy • h:mm a').format(order["date"]),
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              Text(
                order["canteen"],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Text(
                "ORDER ITEMS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 12),
              Column(
                children: order["items"].map<Widget>((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${item["quantity"]}x ${item["name"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "KES ${item["price"] * item["quantity"]}",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "KES ${order["total"]}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              if (isActive) ...[
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.qr_code, size: 64, color: primaryGreen),
                            SizedBox(height: 12),
                            Text(
                              "Receipt Code",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              order["receiptCode"],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: primaryGreen,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Show this code at the canteen",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Long press on receipt for more options",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showReceiptCodeInfo(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Receipt Code Info"),
          content: Text(
            "Your receipt code ${order["receiptCode"]} has been sent to your phone via SMS and WhatsApp. "
            "You can present this code at the canteen to collect your order.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: primaryGreen)),
            ),
          ],
        );
      },
    );
  }
}
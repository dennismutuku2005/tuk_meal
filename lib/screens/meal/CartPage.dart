import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tuk_meal/screens/meal/CheckoutPage.dart';
import 'package:tuk_meal/services/shared_prefs_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  bool isUpdating = false;
  String errorMessage = '';
  double totalPrice = 0.0;
  int totalItems = 0;
  
  int? get items => null;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final token = await SharedPrefsService.getToken();
      if (token == null) {
        throw Exception('Please login to view cart');
      }

      final response = await http.post(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/getcartitems.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_number': token,
          'action': 'get',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          setState(() {
            cartItems = List<Map<String, dynamic>>.from(data['cart_items']);
            totalPrice = (data['total_price'] as num).toDouble();
            totalItems = data['total_items'];
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load cart');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        cartItems = [];
        totalPrice = 0.0;
        totalItems = 0;
      });
    }
  }

  Future<void> _updateQuantity(int cartId, int mealId, int currentQuantity, bool increase) async {
    if (isUpdating) return;

    final newQuantity = increase ? currentQuantity + 1 : currentQuantity - 1;
    
    if (newQuantity < 1) {
      // If decreasing to 0, delete the item
      await _deleteItem(cartId, mealId);
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final token = await SharedPrefsService.getToken();
      if (token == null) {
        throw Exception('Please login to update cart');
      }

      final response = await http.post(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/getcartitems.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_number': token,
          'action': 'update',
          'cart_id': cartId,
          'quantity': newQuantity,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          // Update local state
          final index = cartItems.indexWhere((item) => item['cart_id'] == cartId);
          if (index != -1) {
            setState(() {
              cartItems[index]['quantity'] = newQuantity;
              cartItems[index]['item_total'] = cartItems[index]['price'] * newQuantity;
              _calculateTotals();
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quantity updated to $newQuantity'),
                backgroundColor: primaryGreen,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to update quantity');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Reload cart to sync with server
      await _loadCartItems();
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<void> _deleteItem(int cartId, int mealId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      isUpdating = true;
    });

    try {
      final token = await SharedPrefsService.getToken();
      if (token == null) {
        throw Exception('Please login to modify cart');
      }

      final response = await http.post(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/getcartitems.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_number': token,
          'action': 'delete',
          'cart_id': cartId,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          // Remove from local state
          setState(() {
            cartItems.removeWhere((item) => item['cart_id'] == cartId);
            _calculateTotals();
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item removed from cart'),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to remove item');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Reload cart to sync with server
      await _loadCartItems();
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<void> _clearCart() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear your entire cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;

    setState(() {
      isUpdating = true;
    });

    try {
      final token = await SharedPrefsService.getToken();
      if (token == null) {
        throw Exception('Please login to modify cart');
      }

      final response = await http.post(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/getcartitems.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_number': token,
          'action': 'clear',
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          setState(() {
            cartItems.clear();
            totalPrice = 0.0;
            totalItems = 0;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cart cleared successfully'),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to clear cart');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cart: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  void _calculateTotals() {
    double price = 0.0;
    int items = 0;
    
    for (final item in cartItems) {
      price += (item['item_total']).toDouble();
      items += item['quantity'] as int;
    }
    
    setState(() {
      totalPrice = price;
      totalItems = items;
    });
  }

  void _checkout() {
    if (cartItems.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: cartItems,
          totalPrice: totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your Cart${totalItems > 0 ? ' ($totalItems)' : ''}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cartItems.isNotEmpty && !isLoading)
            IconButton(
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: isUpdating ? Colors.grey : Colors.red[400],
              ),
              onPressed: isUpdating ? null : _clearCart,
              tooltip: 'Clear Cart',
            ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isLoading ? primaryGreen : Colors.black87,
            ),
            onPressed: isLoading ? null : _loadCartItems,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading cart',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCartItems,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some delicious meals to your cart',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                            ),
                            child: Text('Browse Meals', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Cart items list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              final cartId = item['cart_id'] as int;
                              final mealId = item['meal_id'] as int;
                              final quantity = item['quantity'] as int;
                              final itemTotal = (item['item_total'] as num).toDouble();
                              final price = (item['price'] as num).toDouble();
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
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
                                child: Row(
                                  children: [
                                    // Item image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        item['image'] ?? '',
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: primaryGreen,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.fastfood,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Item details
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'] ?? 'Unknown Meal',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['description'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'KES ${price.toStringAsFixed(0)} each',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  'KES ${itemTotal.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F7B0F),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            // Quantity controls
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(Icons.remove, size: 18),
                                                    onPressed: isUpdating
                                                        ? null
                                                        : () => _updateQuantity(cartId, mealId, quantity, false),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  quantity.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: primaryGreen.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.add,
                                                      size: 18,
                                                      color: primaryGreen,
                                                    ),
                                                    onPressed: isUpdating
                                                        ? null
                                                        : () => _updateQuantity(cartId, mealId, quantity, true),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Delete button
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: isUpdating ? Colors.grey : Colors.red[400],
                                        ),
                                        onPressed: isUpdating ? null : () => _deleteItem(cartId, mealId),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Checkout section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'KES ${totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F7B0F),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isUpdating ? null : _checkout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isUpdating
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Proceed to Checkout',
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
                      ],
                    ),
    );
  }
}
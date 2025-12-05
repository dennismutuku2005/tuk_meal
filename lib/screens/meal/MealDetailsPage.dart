// ignore: file_names
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/meal_image_widget.dart';
import 'widgets/meal_details_widget.dart';
import 'widgets/quantity_selector_widget.dart';
import 'widgets/nutrition_info_widget.dart';
import 'widgets/add_to_cart_widget.dart';
import 'package:tuk_meal/services/shared_prefs_service.dart';

class MealDetailPage extends StatefulWidget {
  final Map<String, dynamic> meal;
  const MealDetailPage({super.key, required this.meal});

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> with SingleTickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _quantity = 1;
  bool _isAddingToCart = false;
  bool _shouldNavigateBack = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  void _triggerAnimation() {
    _animationController.forward(from: 0);
  }

  void _onQuantityChanged(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    // Check if user is logged in
    final isLoggedIn = await SharedPrefsService.isLoggedIn();
    final token = await SharedPrefsService.getToken();
    
    if (!isLoggedIn || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Please login to add items to cart'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'LOGIN',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to login page
              // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ),
      );
      setState(() {
        _isAddingToCart = false;
      });
      return;
    }

    try {
      // Convert string ID to integer for the API
      final productId = int.tryParse(widget.meal['id'].toString()) ?? 0;
      
      if (productId == 0) {
        throw Exception('Invalid meal ID');
      }

      final response = await http.post(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/addcart.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobile_number': token,
          'product_id': productId,
          'quantity': _quantity, // Use the selected quantity
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          // Success animation and feedback
          _triggerAnimation();
          
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${_quantity}x ${widget.meal["name"]} added to cart!'),
                ],
              ),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(milliseconds: 1200), // Reduced duration
            ),
          );

          // Use a completer or state flag to handle navigation
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.pop(context, true); // Return success flag
            }
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to add to cart');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to add to cart: ${e.toString()}',
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted && !_shouldNavigateBack) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isAddingToCart,
      onPopInvoked: (didPop) {
        if (_isAddingToCart) {
          // Prevent pop if adding to cart
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait while adding to cart...'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildMealImage(),
              _buildMealDetails(),
              _buildQuantitySelector(),
              _buildNutritionInfo(),
              _buildAddToCartSection(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: _isAddingToCart ? Colors.grey : Colors.black87,
        ),
        onPressed: _isAddingToCart
            ? null
            : () => Navigator.pop(context),
      ),
      title: Text(
        widget.meal['name'] ?? 'Meal Details',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.favorite_border,
            color: _isAddingToCart ? Colors.grey : Colors.black87,
          ),
          onPressed: _isAddingToCart ? null : () {},
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildMealImage() {
    return SliverToBoxAdapter(
      child: MealImageWidget(
        imageUrl: widget.meal['image'] ?? '',
        category: widget.meal['category'] ?? 'N/A',
        primaryColor: primaryGreen,
      ),
    );
  }

  SliverToBoxAdapter _buildMealDetails() {
    return SliverToBoxAdapter(
      child: MealDetailsWidget(
        meal: widget.meal,
        primaryColor: primaryGreen,
      ),
    );
  }

  SliverToBoxAdapter _buildQuantitySelector() {
    return SliverToBoxAdapter(
      child: QuantitySelectorWidget(
        primaryColor: primaryGreen,
        scaleAnimation: _scaleAnimation,
        onAnimationTrigger: _triggerAnimation,
        onQuantityChanged: _onQuantityChanged,
        isEnabled: !_isAddingToCart,
      ),
    );
  }

  SliverToBoxAdapter _buildNutritionInfo() {
    return SliverToBoxAdapter(
      child: NutritionInfoWidget(meal: widget.meal),
    );
  }

  SliverToBoxAdapter _buildAddToCartSection() {
    return SliverToBoxAdapter(
      child: AddToCartWidget(
        primaryColor: primaryGreen,
        scaleAnimation: _scaleAnimation,
        totalPrice: _calculateTotalPrice(),
        onAddToCart: _addToCart,
        onAnimationTrigger: _triggerAnimation,
        isLoading: _isAddingToCart,
      ),
    );
  }

  double _calculateTotalPrice() {
    final priceString = widget.meal['price']?.toString() ?? '0.00';
    final price = double.tryParse(priceString) ?? 0.0;
    return price * _quantity;
  }
}
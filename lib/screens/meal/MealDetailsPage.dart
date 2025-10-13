// ignore: file_names
import 'package:flutter/material.dart';
import 'widgets/meal_image_widget.dart';
import 'widgets/meal_details_widget.dart';
import 'widgets/quantity_selector_widget.dart';
import 'widgets/nutrition_info_widget.dart';
import 'widgets/add_to_cart_widget.dart';

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
  
  int _quantity = 1; // Now managed at the page level

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
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
          icon: const Icon(Icons.favorite_border, color: Colors.black87),
          onPressed: () {},
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
      ),
    );
  }

  double _calculateTotalPrice() {
    final priceString = widget.meal['price']?.toString() ?? '0.00';
    final price = double.tryParse(priceString) ?? 0.0;
    return price * _quantity;
  }

  void _addToCart() {
    final orderItem = {
      'name': widget.meal['name'] ?? 'Unknown Meal',
      'price': _calculateTotalPrice(),
      'quantity': _quantity,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added to cart: ${orderItem['name']}"),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
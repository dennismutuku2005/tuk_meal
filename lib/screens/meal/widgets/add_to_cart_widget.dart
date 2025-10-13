import 'package:flutter/material.dart';

class AddToCartWidget extends StatelessWidget {
  final Color primaryColor;
  final Animation<double> scaleAnimation;
  final double totalPrice;
  final VoidCallback onAddToCart;
  final VoidCallback onAnimationTrigger;

  const AddToCartWidget({
    super.key,
    required this.primaryColor,
    required this.scaleAnimation,
    required this.totalPrice,
    required this.onAddToCart,
    required this.onAnimationTrigger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildPriceSection(),
          const SizedBox(width: 16),
          _buildAddToCartButton(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Price",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            "KES ${totalPrice.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => onAnimationTrigger(),
        onTapUp: (_) {
          onAnimationTrigger();
          onAddToCart();
        },
        onTapCancel: () => onAnimationTrigger(),
        child: ScaleTransition(
          scale: scaleAnimation,
          child: ElevatedButton(
            onPressed: onAddToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: primaryColor.withOpacity(0.3),
            ),
            child: const Text(
              "Add to Cart",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
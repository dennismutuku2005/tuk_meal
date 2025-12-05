import 'package:flutter/material.dart';

class QuantitySelectorWidget extends StatefulWidget {
  final Color primaryColor;
  final Animation<double> scaleAnimation;
  final VoidCallback onAnimationTrigger;
  final ValueChanged<int> onQuantityChanged;

  const QuantitySelectorWidget({
    super.key,
    required this.primaryColor,
    required this.scaleAnimation,
    required this.onAnimationTrigger,
    required this.onQuantityChanged, required bool isEnabled,
  });

  @override
  State<QuantitySelectorWidget> createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget> {
  int _quantity = 1;

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        widget.onQuantityChanged(_quantity);
      });
      widget.onAnimationTrigger();
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      widget.onQuantityChanged(_quantity);
    });
    widget.onAnimationTrigger();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quantity",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildDecrementButton(),
              const SizedBox(width: 20),
              _buildQuantityDisplay(),
              const SizedBox(width: 20),
              _buildIncrementButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecrementButton() {
    return ScaleTransition(
      scale: widget.scaleAnimation,
      child: GestureDetector(
        onTap: _decrementQuantity,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.remove, color: Colors.black87, size: 20),
        ),
      ),
    );
  }

  Widget _buildQuantityDisplay() {
    return Text(
      _quantity.toString(),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildIncrementButton() {
    return ScaleTransition(
      scale: widget.scaleAnimation,
      child: GestureDetector(
        onTap: _incrementQuantity,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.add, color: widget.primaryColor, size: 20),
        ),
      ),
    );
  }
}
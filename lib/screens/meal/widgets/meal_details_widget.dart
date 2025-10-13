import 'package:flutter/material.dart';

class MealDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> meal;
  final Color primaryColor;

  const MealDetailsWidget({
    super.key,
    required this.meal,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 12),
          _buildRatingAndTimeRow(),
          const SizedBox(height: 16),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            meal['name'] ?? 'Unknown Meal',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          "KES ${meal['price']?.toString() ?? '0.00'}",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndTimeRow() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          meal['rating']?.toString() ?? '0.0',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.access_time, color: Colors.grey, size: 20),
        const SizedBox(width: 4),
        Text(
          meal['prep_time'] ?? 'N/A',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      meal['description'] ?? 'A delicious meal prepared with fresh ingredients.',
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 14,
        height: 1.5,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
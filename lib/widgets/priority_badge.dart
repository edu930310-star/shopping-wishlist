import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final int priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (priority) {
      case 1:
        text = 'HIGH';
        color = AppConstants.errorColor;
        break;
      case 2:
        text = 'MEDIUM';
        color = AppConstants.warningColor;
        break;
      case 3:
        text = 'LOW';
        color = AppConstants.successColor;
        break;
      default:
        text = 'MEDIUM';
        color = AppConstants.warningColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

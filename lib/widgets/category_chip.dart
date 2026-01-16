import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showDelete;
  final VoidCallback? onDelete;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(category.color).withOpacity(0.9)
              : AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Color(category.color),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(category.color).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(category.icon), 
              size: 16,
              color: isSelected ? Colors.white : Color(category.color),
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(category.color),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showDelete && onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isSelected ? Colors.white : Color(category.color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Method untuk mendapatkan IconData dari nama icon
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'checkroom':
        return Icons.checkroom;
      case 'devices':
        return Icons.devices; // Electronics harusnya icon devices
      case 'menu_book':
        return Icons.menu_book; // Books icon buku
      case 'home':
        return Icons.home;
      case 'kitchen':
        return Icons.kitchen;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'flight':
        return Icons.flight;
      case 'directions_car':
        return Icons.directions_car;
      case 'spa':
        return Icons.spa;
      case 'music_note':
        return Icons.music_note;
      case 'movie':
        return Icons.movie;
      case 'pets':
        return Icons.pets;
      case 'shopping_bag':
      default:
        return Icons.shopping_bag;
    }
  }
}
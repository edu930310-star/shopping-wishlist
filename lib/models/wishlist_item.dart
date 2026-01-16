import 'package:flutter/material.dart';

class WishlistItem {
  final int? id;
  final String name;
  final String? description;
  final double? price;
  final String? store;
  final String? imageUrl;
  final int priority; 
  final bool isFavorite;
  final bool isPurchased;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  WishlistItem({
    this.id,
    required this.name,
    this.description,
    this.price,
    this.store,
    this.imageUrl,
    this.priority = 2,
    this.isFavorite = false,
    this.isPurchased = false,
    this.categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'store': store,
      'image_url': imageUrl,
      'priority': priority,
      'is_favorite': isFavorite ? 1 : 0,
      'is_purchased': isPurchased ? 1 : 0,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      store: map['store'],
      imageUrl: map['image_url'],
      priority: map['priority'],
      isFavorite: map['is_favorite'] == 1,
      isPurchased: map['is_purchased'] == 1,
      categoryId: map['category_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  WishlistItem copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? store,
    String? imageUrl,
    int? priority,
    bool? isFavorite,
    bool? isPurchased,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      store: store ?? this.store,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      isFavorite: isFavorite ?? this.isFavorite,
      isPurchased: isPurchased ?? this.isPurchased,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get priorityText {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Medium';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}

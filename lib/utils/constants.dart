import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Shopping Wishlist';

  // Colors - Biru Tua & Putih
  static const Color primaryColor = Color(0xFF0A2647); // Biru Tua
  static const Color secondaryColor = Color(0xFF144272); // Biru Sedang
  static const Color accentColor = Color(0xFF205295); // Biru Muda
  static const Color backgroundColor = Color(0xFFFFFFFF); // Putih
  static const Color surfaceColor = Color(0xFFF8F9FA); // Abu-abu sangat muda
  static const Color textColor = Color(0xFF212529); // Hitam gelap
  static const Color lightTextColor = Color(0xFF6C757D); // Abu-abu
  static const Color successColor = Color(0xFF28A745); // Hijau
  static const Color warningColor = Color(0xFFFFC107); // Kuning
  static const Color errorColor = Color(0xFFDC3545); // Merah

  // Padding & Sizes
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Icons
  static const List<String> availableIcons = [
    'shopping_bag',
    'checkroom',
    'devices',
    'menu_book',
    'home',
    'kitchen',
    'sports_esports',
    'fitness_center',
    'restaurant',
    'local_cafe',
    'flight',
    'directions_car',
    'spa',
    'music_note',
    'movie',
    'pets',
  ];

  // Priority Options
  static const Map<int, String> priorityOptions = {
    1: 'High Priority',
    2: 'Medium Priority',
    3: 'Low Priority',
  };

  // Store Suggestions
  static const List<String> storeSuggestions = [
    'Amazon',
    'Tokopedia',
    'Shopee',
    'Blibli',
    'Lazada',
    'Bukalapak',
    'Etsy',
    'Ebay',
    'Local Store',
    'Mall',
    'Supermarket',
    'Online Store',
  ];
}

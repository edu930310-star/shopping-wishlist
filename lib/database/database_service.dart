import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/wishlist_item.dart';
import '../models/category.dart';

class DatabaseService {
  static Database? _database;

  static Future<void> initialize() async {
    // Inisialisasi untuk web/desktop
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Untuk Android/iOS tidak perlu inisialisasi khusus
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final db = await openDatabase(
      'shopping_wishlist.db',
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Tabel categories
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color INTEGER DEFAULT 0xFF9C27B0,
        icon TEXT DEFAULT 'shopping_bag'
      )
    ''');

    // Tabel wishlist_items
    await db.execute('''
      CREATE TABLE wishlist_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL,
        store TEXT,
        image_url TEXT,
        priority INTEGER DEFAULT 2,
        is_favorite INTEGER DEFAULT 0,
        is_purchased INTEGER DEFAULT 0,
        category_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Fashion', 'color': 0xFFE91E63, 'icon': 'checkroom'},
      {'name': 'Electronics', 'color': 0xFF2196F3, 'icon': 'devices'},
      {'name': 'Books', 'color': 0xFFFF9800, 'icon': 'menu_book'},
      {'name': 'Home', 'color': 0xFF4CAF50, 'icon': 'home'},
      {'name': 'Others', 'color': 0xFF9C27B0, 'icon': 'shopping_bag'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ================ CRUD Wishlist Items ================
  static Future<int> insertItem(WishlistItem item) async {
    final db = await database;
    return await db.insert('wishlist_items', item.toMap());
  }

  static Future<List<WishlistItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist_items',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WishlistItem.fromMap(maps[i]));
  }

  static Future<List<WishlistItem>> getItemsByCategory(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist_items',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WishlistItem.fromMap(maps[i]));
  }

  static Future<WishlistItem?> getItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return WishlistItem.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> updateItem(WishlistItem item) async {
    final db = await database;
    return await db.update(
      'wishlist_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'wishlist_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'wishlist_items',
      {'is_favorite': isFavorite ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> togglePurchased(int id, bool isPurchased) async {
    final db = await database;
    return await db.update(
      'wishlist_items',
      {'is_purchased': isPurchased ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================ CRUD Categories ================
  static Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  static Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  static Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> deleteCategory(int id) async {
    final db = await database;
    // Update semua item dengan category ini ke null
    await db.update(
      'wishlist_items',
      {'category_id': null},
      where: 'category_id = ?',
      whereArgs: [id],
    );
    
    // Hapus category
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================ Statistik ================
  static Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final totalItems = await db.rawQuery('SELECT COUNT(*) FROM wishlist_items');
    final totalPrice = await db.rawQuery('SELECT SUM(price) FROM wishlist_items');
    final purchasedItems = await db.rawQuery(
      'SELECT COUNT(*) FROM wishlist_items WHERE is_purchased = 1'
    );
    final favoriteItems = await db.rawQuery(
      'SELECT COUNT(*) FROM wishlist_items WHERE is_favorite = 1'
    );

    return {
      'totalItems': totalItems.first.values.first ?? 0,
      'totalPrice': totalPrice.first.values.first ?? 0.0,
      'purchasedItems': purchasedItems.first.values.first ?? 0,
      'favoriteItems': favoriteItems.first.values.first ?? 0,
    };
  }

  // ================ Search Items ================
  static Future<List<WishlistItem>> searchItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist_items',
      where: 'name LIKE ? OR description LIKE ? OR store LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WishlistItem.fromMap(maps[i]));
  }

  // ================ Get Items by Priority ================
  static Future<List<WishlistItem>> getItemsByPriority(int priority) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist_items',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WishlistItem.fromMap(maps[i]));
  }

  // ================ Get Favorites ================
  static Future<List<WishlistItem>> getFavoriteItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist_items',
      where: 'is_favorite = 1',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WishlistItem.fromMap(maps[i]));
  }

  // ================ Get Purchased ================
  static Future<List<WishlistItem>> getPurchasedItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist_items',
      where: 'is_purchased = 1',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WishlistItem.fromMap(maps[i]));
  }

  // ================ Get Items by Date Range ================
  static Future<List<WishlistItem>> getItemsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist_items',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WishlistItem.fromMap(maps[i]));
  }
}
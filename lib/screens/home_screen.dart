import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/wishlist_item.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../widgets/category_chip.dart';
import '../widgets/priority_badge.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WishlistItem> _items = [];
  List<Category> _categories = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  int? _selectedCategoryId;
  int _selectedFilter = 0; 
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final [items, categories, stats] = await Future.wait([
        DatabaseService.getAllItems(),
        DatabaseService.getAllCategories(),
        DatabaseService.getStatistics(),
      ]);

      setState(() {
        _items = items as List<WishlistItem>;
        _categories = categories as List<Category>;
        _statistics = stats as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<WishlistItem> _filterItems() {
    List<WishlistItem> filtered = _items;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (item.description?.toLowerCase() ?? '')
                .contains(_searchQuery.toLowerCase()) ||
            (item.store?.toLowerCase() ?? '')
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }

    // Filter by type
    if (_selectedFilter == 1) {
      filtered = filtered.where((item) => item.isFavorite).toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered.where((item) => item.isPurchased).toList();
    }

    return filtered;
  }

  Future<void> _toggleFavorite(WishlistItem item) async {
    try {
      await DatabaseService.toggleFavorite(item.id!, !item.isFavorite);
      _loadData();
    } catch (e) {
      _showError('Gagal mengubah favorite: $e');
    }
  }

  Future<void> _togglePurchased(WishlistItem item) async {
    try {
      await DatabaseService.togglePurchased(item.id!, !item.isPurchased);
      _loadData();
    } catch (e) {
      _showError('Gagal mengubah status: $e');
    }
  }

  Future<void> _deleteItem(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteItem(id);
        _loadData();
        _showSuccess('Item berhasil dihapus');
      } catch (e) {
        _showError('Gagal menghapus item: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  Category? _getCategoryById(int? id) {
    if (id == null) return null;
    return _categories.firstWhere((cat) => cat.id == id,
        orElse: () =>
            Category(name: 'Unknown', color: AppConstants.primaryColor.value));
  }

  Widget _buildStatisticsBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: AppConstants.surfaceColor,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE9ECEF)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.shopping_bag,
            value: _statistics['totalItems']?.toString() ?? '0',
            label: 'Total',
            color: AppConstants.primaryColor,
          ),
          _buildStatItem(
            icon: Icons.favorite,
            value: _statistics['favoriteItems']?.toString() ?? '0',
            label: 'Favorite',
            color: AppConstants.errorColor,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            value: _statistics['purchasedItems']?.toString() ?? '0',
            label: 'Dibeli',
            color: AppConstants.successColor,
          ),
          _buildStatItem(
            icon: Icons.attach_money,
            value: _statistics['totalPrice']?.toStringAsFixed(0) ?? '0',
            label: 'Total Harga',
            color: AppConstants.accentColor,
            isPrice: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isPrice = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          isPrice ? 'Rp $value' : value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppConstants.textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppConstants.lightTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    const filters = ['Semua', 'Favorite', 'Dibeli'];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      color: AppConstants.backgroundColor,
      child: Row(
        children: List.generate(filters.length, (index) {
          return Padding(
            padding:
                EdgeInsets.only(right: index < filters.length - 1 ? 12 : 0),
            child: FilterChip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: _selectedFilter == index
                      ? Colors.white
                      : AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: _selectedFilter == index,
              onSelected: (selected) {
                setState(() => _selectedFilter = selected ? index : 0);
              },
              backgroundColor: AppConstants.surfaceColor,
              selectedColor: AppConstants.primaryColor,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _selectedFilter == index
                      ? Colors.transparent
                      : AppConstants.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryChip(
            category: Category(
              name: 'Semua',
              color: AppConstants.primaryColor.value,
              icon: 'shopping_bag',
            ),
            isSelected: _selectedCategoryId == null,
            onTap: () => setState(() => _selectedCategoryId = null),
          ),
          const SizedBox(width: 8),
          ..._categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CategoryChip(
                category: category,
                isSelected: _selectedCategoryId == category.id,
                onTap: () => setState(() => _selectedCategoryId = category.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(WishlistItem item, Category? category) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(
          color: AppConstants.surfaceColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      color: AppConstants.backgroundColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Image/Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: category != null
                    ? Color(category.color).withOpacity(0.1)
                    : AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.shopping_bag,
                              color: AppConstants.primaryColor,
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        item.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: category != null
                              ? Color(category.color)
                              : AppConstants.primaryColor,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Middle: Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppConstants.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PriorityBadge(priority: item.priority),
                    ],
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.lightTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.price != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${item.price!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppConstants.successColor,
                      ),
                    ),
                  ],
                  if (item.store != null && item.store!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.store,
                          size: 14,
                          color: AppConstants.lightTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.store!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (category != null) ...[
                    const SizedBox(height: 8),
                    CategoryChip(
                      category: category,
                      onTap: () =>
                          setState(() => _selectedCategoryId = category.id),
                    ),
                  ],
                ],
              ),
            ),

            // Right: Action Buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: item.isFavorite
                        ? AppConstants.errorColor
                        : AppConstants.lightTextColor,
                    size: 22,
                  ),
                  onPressed: () => _toggleFavorite(item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: Icon(
                    item.isPurchased
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: item.isPurchased
                        ? AppConstants.successColor
                        : AppConstants.lightTextColor,
                    size: 22,
                  ),
                  onPressed: () => _togglePurchased(item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppConstants.lightTextColor,
                    size: 22,
                  ),
                  onPressed: () => _showItemOptions(item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showItemOptions(WishlistItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppConstants.primaryColor),
                title: const Text('Edit Item'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditScreen(
                        item: item,
                        categories: _categories,
                      ),
                    ),
                  );
                  if (result == true) _loadData();
                },
              ),
              ListTile(
                leading: Icon(
                  item.isFavorite ? Icons.favorite_border : Icons.favorite,
                  color: AppConstants.errorColor,
                ),
                title: Text(item.isFavorite
                    ? 'Hapus dari Favorite'
                    : 'Tambah ke Favorite'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleFavorite(item);
                },
              ),
              ListTile(
                leading: Icon(
                  item.isPurchased
                      ? Icons.shopping_bag_outlined
                      : Icons.check_circle_outline,
                  color: AppConstants.successColor,
                ),
                title: Text(item.isPurchased
                    ? 'Tandai Belum Dibeli'
                    : 'Tandai Sudah Dibeli'),
                onTap: () {
                  Navigator.pop(context);
                  _togglePurchased(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppConstants.errorColor),
                title: const Text('Hapus Item'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteItem(item.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppConstants.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppConstants.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                  : 'Wishlist Kosong',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppConstants.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Coba kata kunci lain'
                  : 'Mulai tambahkan barang yang ingin Anda beli',
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.lightTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_searchQuery.isEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditScreen(categories: _categories),
                    ),
                  );
                  if (result == true) _loadData();
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Item Pertama'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsDialog() {
    return AlertDialog(
      title: const Text('Statistik Wishlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatDialogRow(
              'Total Item', _statistics['totalItems']?.toString() ?? '0'),
          _buildStatDialogRow(
              'Item Favorite', _statistics['favoriteItems']?.toString() ?? '0'),
          _buildStatDialogRow(
              'Item Dibeli', _statistics['purchasedItems']?.toString() ?? '0'),
          const Divider(),
          _buildStatDialogRow(
            'Total Nilai Wishlist',
            'Rp ${_statistics['totalPrice']?.toStringAsFixed(0) ?? '0'}',
            isBold: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildStatDialogRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppConstants.successColor : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filterItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildStatisticsDialog(),
              );
            },
            tooltip: 'Statistik',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari item...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics Bar
                _buildStatisticsBar(),

                // Filter Chips
                _buildFilterChips(),

                // Categories Horizontal List
                _buildCategoriesList(),

                // Items List
                Expanded(
                  child: filteredItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                              bottom: 80), // Padding untuk FAB
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final category = _getCategoryById(item.categoryId);

                            return _buildItemCard(item, category);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditScreen(categories: _categories),
            ),
          );

          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

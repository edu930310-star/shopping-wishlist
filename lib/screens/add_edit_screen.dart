import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import '../database/database_service.dart';
import '../models/wishlist_item.dart';
import '../models/category.dart';
import '../utils/constants.dart';

class AddEditScreen extends StatefulWidget {
  final WishlistItem? item;
  final List<Category> categories;

  const AddEditScreen({
    super.key,
    this.item,
    required this.categories,
  });

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _storeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  int _selectedPriority = 2; // 1=High, 2=Medium, 3=Low
  int? _selectedCategoryId;
  bool _isFavorite = false;
  bool _isPurchased = false;
  
  // Tambahkan state untuk preview gambar
  bool _showImagePreview = false;
  String _previewImageUrl = '';

  @override
  void initState() {
    super.initState();

    // Inisialisasi nilai dari item jika sedang edit
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _priceController.text = widget.item!.price?.toString() ?? '';
      _descriptionController.text = widget.item!.description ?? '';
      _storeController.text = widget.item!.store ?? '';
      _imageUrlController.text = widget.item!.imageUrl ?? '';
      _selectedPriority = widget.item!.priority;
      _selectedCategoryId = widget.item!.categoryId;
      _isFavorite = widget.item!.isFavorite;
      _isPurchased = widget.item!.isPurchased;
      
      // Jika ada URL gambar, tampilkan preview
      if (widget.item!.imageUrl?.isNotEmpty ?? false) {
        _previewImageUrl = widget.item!.imageUrl!;
        _showImagePreview = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _storeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Method untuk update preview gambar
  void _updateImagePreview() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty && _isValidUrl(url)) {
      setState(() {
        _previewImageUrl = url;
        _showImagePreview = true;
      });
    } else {
      setState(() {
        _showImagePreview = false;
      });
    }
  }

  // Validasi URL
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && 
             (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final item = WishlistItem(
        id: widget.item?.id,
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        price: _priceController.text.isNotEmpty
            ? double.tryParse(_priceController.text)
            : null,
        store: _storeController.text.isNotEmpty ? _storeController.text : null,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : null,
        priority: _selectedPriority,
        isFavorite: _isFavorite,
        isPurchased: _isPurchased,
        categoryId: _selectedCategoryId,
        createdAt: widget.item?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.item == null) {
        // Insert new item
        await DatabaseService.insertItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil ditambahkan'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      } else {
        // Update existing item
        await DatabaseService.updateItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil diperbarui'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Tambah Item' : 'Edit Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Item
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Item*',
                  hintText: 'Masukkan nama barang',
                  prefixIcon: Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama item wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Deskripsi barang (opsional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Harga
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  hintText: 'Masukkan harga',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Toko
              TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(
                  labelText: 'Toko',
                  hintText: 'Nama toko (opsional)',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // URL Gambar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'URL Gambar',
                      hintText: 'https://example.com/image.jpg (opsional)',
                      prefixIcon: const Icon(Icons.image),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.preview),
                        onPressed: _updateImagePreview,
                        tooltip: 'Preview Gambar',
                      ),
                    ),
                    onChanged: (value) {
                      // Optional: Live preview saat typing
                      // _updateImagePreview();
                    },
                    onFieldSubmitted: (value) {
                      _updateImagePreview();
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Tombol Preview
                  if (_imageUrlController.text.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _updateImagePreview,
                      icon: const Icon(Icons.preview, size: 18),
                      label: const Text('Preview Gambar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                  
                  // Preview Gambar
                  if (_showImagePreview && _previewImageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildImagePreview(_previewImageUrl),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Kategori
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(
                      name: 'Tidak Ada',
                      isSelected: _selectedCategoryId == null,
                      onTap: () => setState(() => _selectedCategoryId = null),
                    ),
                    const SizedBox(width: 8),
                    ...widget.categories.map((category) {
                      return _buildCategoryChip(
                        name: category.name,
                        isSelected: _selectedCategoryId == category.id,
                        color: Color(category.color),
                        icon: category.icon,
                        onTap: () =>
                            setState(() => _selectedCategoryId = category.id),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Priority
              const Text(
                'Prioritas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityOption(
                    value: 1,
                    label: 'Tinggi',
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(width: 12),
                  _buildPriorityOption(
                    value: 2,
                    label: 'Sedang',
                    color: AppConstants.warningColor,
                  ),
                  const SizedBox(width: 12),
                  _buildPriorityOption(
                    value: 3,
                    label: 'Rendah',
                    color: AppConstants.successColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status
              Card(
                color: AppConstants.surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Favorite'),
                        value: _isFavorite,
                        onChanged: (value) =>
                            setState(() => _isFavorite = value),
                        activeThumbColor: AppConstants.primaryColor,
                      ),
                      SwitchListTile(
                        title: const Text('Sudah Dibeli'),
                        value: _isPurchased,
                        onChanged: (value) =>
                            setState(() => _isPurchased = value),
                        activeThumbColor: AppConstants.successColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.item == null ? 'SIMPAN ITEM' : 'UPDATE ITEM',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk preview gambar
  Widget _buildImagePreview(String imageUrl) {
    if (!_isValidUrl(imageUrl)) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'URL tidak valid. Gunakan format: http:// atau https://',
                style: TextStyle(color: Colors.amber[800]),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Gambar:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryColor,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gagal memuat gambar',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cek URL atau koneksi internet',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // URL yang dimasukkan
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'URL: $imageUrl',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        
        // Tombol untuk menyembunyikan preview
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _showImagePreview = false;
              });
            },
            icon: const Icon(Icons.close, size: 14),
            label: const Text('Sembunyikan'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String name,
    required bool isSelected,
    Color? color,
    String? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppConstants.primaryColor)
              : (color?.withOpacity(0.1) ?? AppConstants.surfaceColor),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (color ?? AppConstants.primaryColor),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                _getIcon(icon),
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (color ?? AppConstants.primaryColor),
              ),
            if (icon != null) const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (color ?? AppConstants.primaryColor),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'checkroom':
        return Icons.checkroom;
      case 'devices':
        return Icons.devices;
      case 'menu_book':
        return Icons.menu_book;
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
      default:
        return Icons.shopping_bag;
    }
  }

  Widget _buildPriorityOption({
    required int value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedPriority == value ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedPriority == value
                  ? Colors.transparent
                  : color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _getPriorityIcon(value),
                color: _selectedPriority == value ? Colors.white : color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _selectedPriority == value ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icons.warning;
      case 2:
        return Icons.info;
      case 3:
        return Icons.low_priority;
      default:
        return Icons.info;
    }
  }
}
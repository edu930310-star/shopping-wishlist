class Category {
  final int? id;
  final String name;
  final int color;
  final String icon;

  Category({
    this.id,
    required this.name,
    this.color = 0xFF0A2647, // Default biru tua
    this.icon = 'shopping_bag',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      icon: map['icon'],
    );
  }

  Category copyWith({
    int? id,
    String? name,
    int? color,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

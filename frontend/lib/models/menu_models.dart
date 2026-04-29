class MenuItem {
  final int id;
  final String name;
  final String category;
  final double price;
  final int prepTime;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.prepTime,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'],
      prepTime: json['prep_time'],
    );
  }
}

class CartItem {
  final int id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  MenuItem toMenuItem() {
    return MenuItem(
      id: id,
      name: name,
      category: '', // Not needed for cart increment
      price: price,
      prepTime: 0, // Not needed for cart increment
    );
  }
}

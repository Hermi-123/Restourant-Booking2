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
      price: json['price'] is int ? (json['price'] as int).toDouble() : double.parse(json['price'].toString()),
      prepTime: json['prep_time'],
    );
  }
}

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  double get totalPrice => menuItem.price * quantity;
}

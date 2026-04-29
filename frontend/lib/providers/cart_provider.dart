import 'package:flutter/foundation.dart';
import '../models/menu_models.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  void addItem(MenuItem menuItem) {
    if (_items.containsKey(menuItem.id.toString())) {
      _items[menuItem.id.toString()]!.quantity += 1;
    } else {
      _items[menuItem.id.toString()] = CartItem(
        id: menuItem.id,
        name: menuItem.name,
        price: menuItem.price,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }
  
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

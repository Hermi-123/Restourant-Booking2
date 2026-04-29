import 'package:flutter/foundation.dart';
import '../models/menu_models.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(MenuItem menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity += 1;
    } else {
      _items[menuItem.id] = CartItem(menuItem: menuItem);
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }
  
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout() async {
    if (_items.isEmpty) return false;

    final itemsForApi = _items.values.map((item) {
      return {
        'menu_item_id': item.menuItem.id,
        'quantity': item.quantity,
      };
    }).toList();

    final response = await ApiService.placeOrder(itemsForApi);
    if (response != null) {
      clearCart();
      return true;
    }
    return false;
  }
}

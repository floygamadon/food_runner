import 'menu_item.dart';

class CartItem {
  final MenuItemModel menuItem;
  final int quantity;

  CartItem({
    required this.menuItem,
    required this.quantity,
  });

  double get subtotal => menuItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItem.id,
      'name': menuItem.name,
      'price': menuItem.price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}
import 'package:flutter/material.dart';
import 'package:coffee_app/models/product_model.dart';
import 'package:coffee_app/models/order_model.dart';
import 'package:coffee_app/services/order_service.dart';
import 'package:coffee_app/services/phone_auth_service.dart';
import 'package:coffee_app/services/loyalty_service.dart';

class CartScreen extends StatefulWidget {
  final List<ProductModel> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<ProductModel> _items;
  final OrderService _orderService = OrderService();
  final PhoneAuthService _authService = PhoneAuthService();
  final LoyaltyService _loyaltyService = LoyaltyService();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _items = widget.cartItems;
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.price);

  // Group items by name+price to show quantity
  List<MapEntry<ProductModel, int>> get _groupedItems {
    final Map<String, MapEntry<ProductModel, int>> grouped = {};
    for (var item in _items) {
      final key = '${item.name}_${item.price}';
      if (grouped.containsKey(key)) {
        grouped[key] = MapEntry(item, grouped[key]!.value + 1);
      } else {
        grouped[key] = MapEntry(item, 1);
      }
    }
    return grouped.values.toList();
  }

  void _incrementItem(ProductModel product) {
    setState(() => _items.add(product));
  }

  void _decrementItem(ProductModel product) {
    setState(() {
      final index = _items.indexWhere(
          (item) => item.name == product.name && item.price == product.price);
      if (index != -1) _items.removeAt(index);
    });
  }

  Future<void> _placeOrder() async {
    if (_items.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    try {
      final order = OrderModel(
        id: '',
        userPhone: _authService.currentUser?.phoneNumber ?? 'unknown',
        items: _items,
        total: _total,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _orderService.placeOrder(order);
      await _loyaltyService.addStars(order.userPhone, order.total);

      if (mounted) {
        setState(() {
          _items.clear();
          widget.cartItems.clear();
        });
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF3D2314),
            title: const Text('Order Placed! ☕',
                style: TextStyle(color: Color(0xFFD4A96A))),
            content: Text(
              'Your order has been placed successfully!\nYou earned ${order.total.floor()} stars ⭐',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A96A)),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    }

    setState(() => _isPlacingOrder = false);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedItems;

    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'My Cart',
          style: TextStyle(color: Color(0xFFD4A96A)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4A96A)),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Color(0xFFD4A96A)),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final item = grouped[index].key;
                      final qty = grouped[index].value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D2314),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.coffee,
                                        size: 40, color: Color(0xFFD4A96A)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)} each',
                                    style: const TextStyle(
                                      color: Color(0xFFD4A96A),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Row(
                              children: [
                                _qtyBtn(Icons.remove, () => _decrementItem(item)),
                                Container(
                                  width: 32,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _qtyBtn(Icons.add, () => _incrementItem(item)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D2314),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFD4A96A),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isPlacingOrder ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A96A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isPlacingOrder
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Place Order',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF2C1810),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD4A96A)),
        ),
        child: Icon(icon, color: const Color(0xFFD4A96A), size: 16),
      ),
    );
  }
}
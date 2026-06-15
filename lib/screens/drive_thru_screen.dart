import 'package:flutter/material.dart';
import 'package:coffee_app/models/product_model.dart';
import 'package:coffee_app/models/order_model.dart';
import 'package:coffee_app/services/firestore_service.dart';
import 'package:coffee_app/services/order_service.dart';

class DriveThruScreen extends StatefulWidget {
  const DriveThruScreen({super.key});

  @override
  State<DriveThruScreen> createState() => _DriveThruScreenState();
}

class _DriveThruScreenState extends State<DriveThruScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final OrderService _orderService = OrderService();
  List<ProductModel> _products = [];
  final List<ProductModel> _cart = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _firestoreService.getProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  double get _total => _cart.fold(0, (sum, item) => sum + item.price);

  Future<void> _sendToKitchen() async {
    if (_cart.isEmpty) return;

    final order = OrderModel(
      id: '',
      userPhone: 'DRIVE-THRU',
      items: List.from(_cart),
      total: _total,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _orderService.placeOrder(order);

    setState(() => _cart.clear());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order sent to kitchen! ☕'),
          backgroundColor: Color(0xFFD4A96A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text('Drive-Thru — Lane 1',
            style: TextStyle(color: Color(0xFFD4A96A))),
        iconTheme: const IconThemeData(color: Color(0xFFD4A96A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4A96A)))
          : Row(
              children: [
                // Product grid
                Expanded(
                  flex: 2,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return GestureDetector(
                        onTap: () => setState(() => _cart.add(product)),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D2314),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD4A96A)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.coffee,
                                  color: Color(0xFFD4A96A), size: 32),
                              const SizedBox(height: 4),
                              Text(
                                product.name,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Color(0xFFD4A96A), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Order summary
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color(0xFF3D2314),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('ORDER',
                            style: TextStyle(
                                color: Color(0xFFD4A96A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final item = _cart[index];
                              return ListTile(
                                dense: true,
                                title: Text(item.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                                trailing: Text('\$${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFFD4A96A), fontSize: 12)),
                                onTap: () => setState(() => _cart.removeAt(index)),
                              );
                            },
                          ),
                        ),
                        const Divider(color: Color(0xFFD4A96A)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('\$${_total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Color(0xFFD4A96A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _sendToKitchen,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A96A)),
                            child: const Text('Send to Kitchen',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
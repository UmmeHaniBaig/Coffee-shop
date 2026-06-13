import 'package:flutter/material.dart';
import 'package:coffee_app/models/product_model.dart';
import 'package:coffee_app/services/firestore_service.dart';
import 'package:coffee_app/screens/cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<ProductModel> _cartItems = [];
  String _selectedCategory = 'All';
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final products = _selectedCategory == 'All'
          ? await _firestoreService.getProducts()
          : await _firestoreService.getProductsByCategory(_selectedCategory);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addToCart(ProductModel product) {
    setState(() => _cartItems.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        backgroundColor: const Color(0xFFD4A96A),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text('Our Menu',
            style: TextStyle(color: Color(0xFFD4A96A))),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart,
                    color: Color(0xFFD4A96A)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CartScreen(cartItems: _cartItems),
                    ),
                  );
                },
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(
                        minWidth: 16, minHeight: 16),
                    child: Text('${_cartItems.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Hot Coffee', 'Cold Coffee'].map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    _loadProducts();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedCategory == category
                          ? const Color(0xFFD4A96A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4A96A)),
                    ),
                    child: Text(category,
                        style: TextStyle(
                            color: _selectedCategory == category
                                ? Colors.white
                                : const Color(0xFFD4A96A))),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFD4A96A)))
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error,
                                style: const TextStyle(color: Colors.red)),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              child: const Text('Retry'),
                            )
                          ],
                        ),
                      )
                    : _products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('No products found',
                                    style:
                                        TextStyle(color: Colors.white70)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadProducts,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFD4A96A)),
                                  child: const Text('Retry',
                                      style:
                                          TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3D2314),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                      child: Image.network(
                                        product.imageUrl,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(Icons.coffee,
                                                size: 80,
                                                color: Color(0xFFD4A96A)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(product.description,
                                              style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 11),
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                  '\$${product.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      color: Color(
                                                          0xFFD4A96A),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),
                                              GestureDetector(
                                                onTap: () =>
                                                    _addToCart(product),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(
                                                          4),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xFFD4A96A),
                                                          shape: BoxShape
                                                              .circle),
                                                  child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
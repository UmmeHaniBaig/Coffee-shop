import 'package:flutter/material.dart';
import 'package:coffee_app/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'Medium';
  int _quantity = 1;

  final Map<String, double> _sizePriceAdd = {
    'Small': -0.50,
    'Medium': 0.0,
    'Large': 0.75,
  };

  double get _unitPrice => widget.product.price + (_sizePriceAdd[_selectedSize] ?? 0);
  double get _totalPrice => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button + image
                    Stack(
                      children: [
                        Image.network(
                          product.imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 250,
                            color: const Color(0xFF3D2314),
                            child: const Icon(Icons.coffee,
                                size: 100, color: Color(0xFFD4A96A)),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: Color(0xFFD4A96A),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 24),

                          // Size selector
                          const Text(
                            'SIZE',
                            style: TextStyle(
                              color: Color(0xFFD4A96A),
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: ['Small', 'Medium', 'Large'].map((size) {
                              final isSelected = _selectedSize == size;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedSize = size),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFD4A96A)
                                          : const Color(0xFF3D2314),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFD4A96A),
                                        width: isSelected ? 0 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          size,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFFD4A96A),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _sizePriceAdd[size] == 0
                                              ? 'Base'
                                              : (_sizePriceAdd[size]! > 0
                                                  ? '+\$${_sizePriceAdd[size]!.toStringAsFixed(2)}'
                                                  : '-\$${_sizePriceAdd[size]!.abs().toStringAsFixed(2)}'),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white70
                                                : Colors.white54,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Quantity selector
                          const Text(
                            'QUANTITY',
                            style: TextStyle(
                              color: Color(0xFFD4A96A),
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _qtyButton(Icons.remove, () {
                                if (_quantity > 1) setState(() => _quantity--);
                              }),
                              Container(
                                width: 60,
                                alignment: Alignment.center,
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _qtyButton(Icons.add, () {
                                setState(() => _quantity++);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF3D2314),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          '\$${_totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFD4A96A),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final customized = ProductModel(
                        id: product.id,
                        name: '${product.name} ($_selectedSize)',
                        price: _unitPrice,
                        description: product.description,
                        category: product.category,
                        imageUrl: product.imageUrl,
                      );
                      Navigator.pop(
                        context,
                        List.generate(_quantity, (_) => customized),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A96A),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF2C1810),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4A96A)),
        ),
        child: Icon(icon, color: const Color(0xFFD4A96A)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:coffee_app/models/product_model.dart';
import 'package:coffee_app/services/firestore_service.dart';
import 'package:coffee_app/services/phone_auth_service.dart';
import 'package:coffee_app/services/loyalty_service.dart';
import 'package:coffee_app/screens/cart_screen.dart';
import 'package:coffee_app/screens/phone_login_screen.dart';
import 'package:coffee_app/screens/qr_pay_screen.dart';
import 'package:coffee_app/screens/admin_dashboard_screen.dart';
import 'package:coffee_app/screens/drive_thru_screen.dart';
import 'package:coffee_app/screens/kitchen_display_screen.dart';
import 'package:coffee_app/screens/product_detail_screen.dart';
import 'package:coffee_app/screens/order_history_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final LoyaltyService _loyaltyService = LoyaltyService();
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

  Future<void> _openProductDetail(ProductModel product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
    if (result != null && result is List<ProductModel>) {
      if (!_phoneAuthService.isLoggedIn) {
        _showLoginPrompt();
        return;
      }
      setState(() => _cartItems.addAll(result));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.length}x ${product.name} added to cart!'),
            backgroundColor: const Color(0xFFD4A96A),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _openCart() {
    if (!_phoneAuthService.isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cartItems: _cartItems),
      ),
    ).then((_) => setState(() {}));
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3D2314),
        title: const Text('Login Required',
            style: TextStyle(color: Color(0xFFD4A96A))),
        content: const Text(
          'Please login to add items to cart and place orders.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
              ).then((_) => setState(() {}));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A96A)),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _goToProfile() async {
    if (!_phoneAuthService.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
      ).then((_) => setState(() {}));
    } else {
      final phone = _phoneAuthService.currentUser?.phoneNumber ?? '';
      final loyalty = await _loyaltyService.getLoyalty(phone);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF3D2314),
          title: const Text('My Account', style: TextStyle(color: Color(0xFFD4A96A))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone: $phone',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4A96A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFD4A96A)),
                        const SizedBox(width: 8),
                        Text(
                          '${loyalty.stars} Stars',
                          style: const TextStyle(
                            color: Color(0xFFD4A96A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tier: ${loyalty.tier} Member',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
              },
              child: const Text('Order History', style: TextStyle(color: Color(0xFFD4A96A))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _phoneAuthService.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() => _cartItems.clear());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _openQRPay() {
    if (!_phoneAuthService.isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRPayScreen()),
    );
  }

  void _showStaffMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3D2314),
        title: const Text('Staff Access',
            style: TextStyle(color: Color(0xFFD4A96A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFFD4A96A)),
              title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Color(0xFFD4A96A)),
              title: const Text('Drive-Thru', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const DriveThruScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Color(0xFFD4A96A)),
              title: const Text('Kitchen Display', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const KitchenDisplayScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: GestureDetector(
          onLongPress: _showStaffMenu,
          child: const Text('Our Menu',
              style: TextStyle(color: Color(0xFFD4A96A))),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _phoneAuthService.isLoggedIn
                  ? Icons.account_circle
                  : Icons.account_circle_outlined,
              color: const Color(0xFFD4A96A),
            ),
            onPressed: _goToProfile,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code, color: Color(0xFFD4A96A)),
            onPressed: _openQRPay,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart,
                    color: Color(0xFFD4A96A)),
                onPressed: _openCart,
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
                              return GestureDetector(
                                onTap: () => _openProductDetail(product),
                                child: Container(
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
                                                      _openProductDetail(product),
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
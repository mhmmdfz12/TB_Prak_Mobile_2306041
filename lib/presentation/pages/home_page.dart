import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/helpers/response_parser.dart';
import '../../data/network/api_client.dart';
import 'cart/cart_page.dart';
import 'orders/orders_page.dart';
import 'product/products_page.dart';
import 'profile/profile_page.dart';
import 'wishlist/wishlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final data = await ApiClient(widget.prefs).get('/cart', auth: true);
      if (mounted) setState(() => _cartCount = listFrom(data).length);
    } catch (_) {
      // Counter keranjang tidak boleh membuat halaman utama gagal dibuka.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ProductsPage(prefs: widget.prefs, refreshCart: _loadCartCount),
      WishlistPage(prefs: widget.prefs),
      CartPage(prefs: widget.prefs, onChanged: _loadCartCount),
      OrdersPage(prefs: widget.prefs),
      ProfilePage(prefs: widget.prefs),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) _loadCartCount();
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront),
            label: 'Produk',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Keranjang',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

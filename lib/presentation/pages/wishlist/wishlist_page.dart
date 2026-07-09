import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/formatters.dart';
import '../../../core/helpers/response_parser.dart';
import '../../../data/local/wishlist_store.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_image.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  Future<void> _remove(String productId) async {
    await WishlistStore.remove(widget.prefs, productId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final products = WishlistStore.getAll(widget.prefs);

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist Lokal')),
      body: products.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              message: 'Wishlist masih kosong',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (_, index) {
                final product = products[index];
                final productId = textOf(product, ['id', '_id']);

                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 58,
                      height: 58,
                      child: ProductImage(product: product),
                    ),
                    title: Text(textOf(product, ['name', 'title'], 'Produk')),
                    subtitle: Text(AppFormatters.price(product['price'])),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _remove(productId),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

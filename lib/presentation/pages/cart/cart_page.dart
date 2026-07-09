import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/formatters.dart';
import '../../../core/helpers/response_parser.dart';
import '../../../core/helpers/ui_helpers.dart';
import '../../../data/network/api_client.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_image.dart';
import '../checkout/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.prefs, required this.onChanged});

  final SharedPreferences prefs;
  final Future<void> Function() onChanged;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient(widget.prefs).get('/cart', auth: true);
      _items = listFrom(data);
      await widget.onChanged();
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateQuantity(String cartId, int quantity) async {
    if (quantity < 1) return;
    try {
      await ApiClient(
        widget.prefs,
      ).put('/cart/$cartId', auth: true, body: {'quantity': quantity});
      await _loadCart();
    } catch (e) {
      if (mounted) showMessage(context, e);
    }
  }

  Future<void> _removeItem(String cartId) async {
    try {
      await ApiClient(widget.prefs).delete('/cart/$cartId', auth: true);
      await _loadCart();
    } catch (e) {
      if (mounted) showMessage(context, e);
    }
  }

  Future<void> _clearCart() async {
    final confirmed = await showConfirmDialog(
      context,
      'Kosongkan semua item keranjang?',
    );
    if (!confirmed) return;

    try {
      await ApiClient(widget.prefs).delete('/cart', auth: true);
      await _loadCart();
    } catch (e) {
      if (mounted) showMessage(context, e);
    }
  }

  double get _grandTotal {
    return _items.fold(0, (sum, item) {
      final cartItem = Map<String, dynamic>.from(item);
      final product = cartItem['product'] is Map
          ? Map<String, dynamic>.from(cartItem['product'])
          : cartItem;
      final quantity = intOf(cartItem['quantity']);
      return sum +
          (doubleOf(
            cartItem['subtotal'] ?? doubleOf(product['price']) * quantity,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_sweep),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCart,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? const EmptyState(
                icon: Icons.shopping_cart_outlined,
                message: 'Keranjang masih kosong',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (_, index) => _CartItemCard(
                  item: Map<String, dynamic>.from(_items[index]),
                  onUpdate: _updateQuantity,
                  onRemove: _removeItem,
                ),
              ),
      ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total: ${AppFormatters.price(_grandTotal)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutPage(
                            prefs: widget.prefs,
                            onDone: _loadCart,
                          ),
                        ),
                      ),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onUpdate,
    required this.onRemove,
  });

  final Map<String, dynamic> item;
  final Future<void> Function(String cartId, int quantity) onUpdate;
  final Future<void> Function(String cartId) onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item['product'] is Map
        ? Map<String, dynamic>.from(item['product'])
        : item;
    final cartId = textOf(item, ['id', '_id', 'cart_id']);
    final quantity = intOf(item['quantity']);
    final price = doubleOf(item['price'] ?? product['price']);
    final subtotal = doubleOf(item['subtotal'] ?? price * quantity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 74,
              height: 74,
              child: ProductImage(product: product),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textOf(product, ['name', 'title'], 'Produk'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(AppFormatters.price(price)),
                  Text('Subtotal: ${AppFormatters.price(subtotal)}'),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => onUpdate(cartId, quantity - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$quantity'),
                    IconButton(
                      onPressed: () => onUpdate(cartId, quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => onRemove(cartId),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

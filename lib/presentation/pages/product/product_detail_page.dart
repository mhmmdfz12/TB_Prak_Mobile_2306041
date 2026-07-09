import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/formatters.dart';
import '../../../core/helpers/response_parser.dart';
import '../../../core/helpers/ui_helpers.dart';
import '../../../data/network/api_client.dart';
import '../../widgets/product_image.dart';
import 'product_helpers.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.prefs,
    required this.productId,
    required this.refreshCart,
  });

  final SharedPreferences prefs;
  final String productId;
  final Future<void> Function() refreshCart;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _commentController = TextEditingController();
  Map<String, dynamic> _product = {};
  List<dynamic> _reviews = [];
  double _rating = 5;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final api = ApiClient(widget.prefs);
      final productData = await api.get('/products/${widget.productId}');
      final reviewData = await api.get('/reviews/product/${widget.productId}');

      setState(() {
        _product = mapFrom(productData);
        _reviews = listFrom(reviewData);
      });
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addToCart() async {
    try {
      await ApiClient(widget.prefs).post(
        '/cart',
        auth: true,
        body: {'product_id': widget.productId, 'quantity': 1},
      );
      await widget.refreshCart();
      if (mounted) showMessage(context, 'Produk ditambahkan ke keranjang');
    } catch (e) {
      if (mounted) showMessage(context, e);
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      showMessage(context, 'Komentar wajib diisi');
      return;
    }

    try {
      await ApiClient(widget.prefs).post(
        '/reviews/product/${widget.productId}',
        auth: true,
        body: {
          'rating': _rating.round(),
          'comment': _commentController.text.trim(),
        },
      );
      _commentController.clear();
      await _loadDetail();
      if (mounted) showMessage(context, 'Ulasan berhasil dikirim');
    } catch (e) {
      if (mounted) showMessage(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: ProductImage(product: _product, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Text(
            textOf(_product, ['name', 'title'], 'Produk'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppFormatters.price(_product['price']),
            style: const TextStyle(
              fontSize: 22,
              color: Colors.deepOrange,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text('Kategori: ${categoryName(_product)}'),
          Text('Stok: ${textOf(_product, ['stock', 'stok'], '0')}'),
          const SizedBox(height: 12),
          Text(
            textOf(_product, ['description', 'desc'], 'Tidak ada deskripsi.'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Tambah ke Keranjang'),
          ),
          const Divider(height: 32),
          const Text(
            'Ulasan Produk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._reviews.map((item) {
            final review = Map<String, dynamic>.from(item);
            return Card(
              child: ListTile(
                title: RatingBarIndicator(
                  rating: doubleOf(review['rating']),
                  itemSize: 18,
                  itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: Colors.amber),
                ),
                subtitle: Text(textOf(review, ['comment', 'review'], '-')),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Tulis Ulasan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (value) => _rating = value,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Komentar',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _submitReview,
            child: const Text('Kirim Ulasan'),
          ),
        ],
      ),
    );
  }
}

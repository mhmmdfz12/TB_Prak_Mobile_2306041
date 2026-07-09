import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/formatters.dart';
import '../../../core/helpers/response_parser.dart';
import '../../../data/local/wishlist_store.dart';
import '../../widgets/product_image.dart';
import 'product_detail_page.dart';
import 'product_helpers.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.prefs,
    required this.product,
    required this.refreshCart,
  });

  final SharedPreferences prefs;
  final Map<String, dynamic> product;
  final Future<void> Function() refreshCart;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _liked;

  String get _productId => textOf(widget.product, ['id', '_id']);

  @override
  void initState() {
    super.initState();
    _liked = WishlistStore.contains(widget.prefs, _productId);
  }

  Future<void> _toggleWishlist() async {
    await WishlistStore.toggle(widget.prefs, widget.product);
    setState(() => _liked = !_liked);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(
            prefs: widget.prefs,
            productId: _productId,
            refreshCart: widget.refreshCart,
          ),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: ProductImage(product: product)),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: IconButton.filledTonal(
                      onPressed: _toggleWishlist,
                      icon: Icon(
                        _liked ? Icons.favorite : Icons.favorite_border,
                        color: _liked ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textOf(product, ['name', 'title'], 'Produk'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.price(product['price']),
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    categoryName(product),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

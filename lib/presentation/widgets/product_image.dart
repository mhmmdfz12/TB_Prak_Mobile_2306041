import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/helpers/response_parser.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
  });

  final Map product;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = textOf(product, [
      'image',
      'image_url',
      'imageUrl',
      'thumbnail',
      'photo',
    ]);

    if (url.isEmpty) {
      return Container(
        color: Colors.black12,
        child: const Icon(Icons.image, size: 48),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => Container(
        color: Colors.black12,
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}

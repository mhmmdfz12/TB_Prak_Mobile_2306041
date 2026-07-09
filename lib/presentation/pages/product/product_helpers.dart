import '../../../core/helpers/response_parser.dart';

/// Mengambil nama kategori dari format API lokal.
/// Backend mengirim relasi kategori dengan key `categories`.
String categoryName(Map product) {
  final category = product['category'] ?? product['categories'];
  if (category is Map) return textOf(category, ['name', 'title', 'slug'], '-');
  return textOf(product, ['category_name', 'category', 'categories'], '-');
}

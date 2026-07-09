/// Helper untuk membaca variasi response API.
/// Backend biasanya membungkus data di dalam key `data`.
List<dynamic> listFrom(dynamic data) {
  if (data is List) return data;

  if (data is Map) {
    final directListKeys = [
      'products',
      'items',
      'orders',
      'categories',
      'reviews',
      'cart',
    ];

    for (final key in directListKeys) {
      final value = data[key];
      if (value is List) return value;
    }

    // Response API sering berbentuk { data: { items: [...] } }.
    final nestedData = data['data'];
    if (nestedData is List) return nestedData;
    if (nestedData is Map) return listFrom(nestedData);
  }

  return [];
}

/// Helper untuk membaca response detail seperti profil dan detail produk.
Map<String, dynamic> mapFrom(dynamic data) {
  if (data is Map<String, dynamic>) {
    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) return nestedData;

    final user = data['user'];
    if (user is Map<String, dynamic>) return user;

    return data;
  }

  return {};
}

/// Mengambil teks dari beberapa kemungkinan nama field.
String textOf(Map data, List<String> keys, [String fallback = '']) {
  for (final key in keys) {
    final value = data[key];
    if (value != null && value.toString().isNotEmpty) return value.toString();
  }
  return fallback;
}

int intOf(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double doubleOf(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

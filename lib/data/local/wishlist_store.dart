import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/helpers/response_parser.dart';

class WishlistStore {
  WishlistStore._();

  static const _key = 'wishlist';

  static List<Map<String, dynamic>> getAll(SharedPreferences prefs) {
    final rawItems = prefs.getStringList(_key) ?? [];
    return rawItems
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  static bool contains(SharedPreferences prefs, String productId) {
    return getAll(
      prefs,
    ).any((item) => textOf(item, ['id', '_id']) == productId);
  }

  static Future<void> toggle(
    SharedPreferences prefs,
    Map<String, dynamic> product,
  ) async {
    final list = getAll(prefs);
    final productId = textOf(product, ['id', '_id']);
    final alreadySaved = list.any(
      (item) => textOf(item, ['id', '_id']) == productId,
    );

    if (alreadySaved) {
      list.removeWhere((item) => textOf(item, ['id', '_id']) == productId);
    } else {
      list.add(product);
    }

    await prefs.setStringList(_key, list.map(jsonEncode).toList());
  }

  static Future<void> remove(SharedPreferences prefs, String productId) async {
    final list = getAll(prefs)
      ..removeWhere((item) => textOf(item, ['id', '_id']) == productId);
    await prefs.setStringList(_key, list.map(jsonEncode).toList());
  }
}

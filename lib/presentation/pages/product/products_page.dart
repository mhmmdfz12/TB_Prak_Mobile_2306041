import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/response_parser.dart';
import '../../../data/network/api_client.dart';
import '../../widgets/empty_state.dart';
import 'product_card.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({
    super.key,
    required this.prefs,
    required this.refreshCart,
  });

  final SharedPreferences prefs;
  final Future<void> Function() refreshCart;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  final List<dynamic> _products = [];
  List<dynamic> _categories = [];

  String _selectedCategory = '';
  String _sort = 'newest';
  String _error = '';
  int _page = 1;
  bool _loading = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts(reset: true);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final nearBottom =
        _scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 240;
    if (nearBottom && !_loading && _hasMore) _loadProducts();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiClient(widget.prefs).get('/categories');
      if (mounted) setState(() => _categories = listFrom(data));
    } catch (_) {
      // Filter kategori bersifat pendukung, jadi halaman produk tetap dapat dibuka.
    }
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _products.clear();
      _hasMore = true;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final query = <String, String>{
        'page': '$_page',
        'limit': '10',
        'sort': _sort,
      };

      if (_searchController.text.trim().isNotEmpty)
        query['search'] = _searchController.text.trim();
      if (_selectedCategory.isNotEmpty)
        query['category_id'] = _selectedCategory;

      final path = '/products?${Uri(queryParameters: query).query}';
      final data = await ApiClient(widget.prefs).get(path);
      final newItems = listFrom(data);

      setState(() {
        _products.addAll(newItems);
        _page++;
        _hasMore = newItems.length >= 10;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IzShop')),
      body: RefreshIndicator(
        onRefresh: () => _loadProducts(reset: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _FilterSection()),
            if (_products.isEmpty && !_loading)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.inventory_2,
                  message: 'Produk belum tersedia',
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .68,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _products.length,
                itemBuilder: (_, index) {
                  return ProductCard(
                    prefs: widget.prefs,
                    product: Map<String, dynamic>.from(_products[index]),
                    refreshCart: widget.refreshCart,
                  );
                },
              ),
            ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _FilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _loadProducts(reset: true),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari produk',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () => _loadProducts(reset: true),
                icon: const Icon(Icons.tune),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _selectedCategory.isEmpty,
                  onSelected: (_) {
                    _selectedCategory = '';
                    _loadProducts(reset: true);
                  },
                ),
                ..._categories.map((category) {
                  final categoryMap = Map<String, dynamic>.from(category);
                  final categoryId = textOf(categoryMap, ['id', '_id']);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(textOf(categoryMap, ['name', 'title'])),
                      selected: _selectedCategory == categoryId,
                      onSelected: (_) {
                        _selectedCategory = categoryId;
                        _loadProducts(reset: true);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _sort,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Urutkan',
            ),
            items: const [
              DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
              DropdownMenuItem(
                value: 'price_asc',
                child: Text('Harga termurah'),
              ),
              DropdownMenuItem(
                value: 'price_desc',
                child: Text('Harga termahal'),
              ),
            ],
            onChanged: (value) {
              _sort = value ?? 'newest';
              _loadProducts(reset: true);
            },
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}

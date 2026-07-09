import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/formatters.dart';
import '../../../core/helpers/response_parser.dart';
import '../../../core/helpers/ui_helpers.dart';
import '../../../data/network/api_client.dart';
import '../../widgets/empty_state.dart';
import 'order_detail_page.dart';
import 'order_status.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient(widget.prefs).get('/orders', auth: true);
      _orders = listFrom(data);
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _orderSubtitle(Map<String, dynamic> order) {
    final date = textOf(order, ['created_at', 'createdAt', 'date'], '-');
    final items = listFrom(order['items'] ?? order['order_items'] ?? []);

    // Jika backend mengirim daftar item, tampilkan nama produk agar riwayat lebih jelas.
    if (items.isNotEmpty) {
      final productNames = items
          .take(2)
          .map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return textOf(map, ['product_name', 'name'], 'Produk');
          })
          .join(', ');
      final extraCount = items.length > 2
          ? ' +${items.length - 2} produk lain'
          : '';
      return '$date\n$productNames$extraCount';
    }

    final count = intOf(order['items_count']);
    if (count > 0) return '$date\n$count produk';

    return date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long,
                message: 'Belum ada pesanan',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _orders.length,
                itemBuilder: (_, index) {
                  final order = Map<String, dynamic>.from(_orders[index]);
                  final id = textOf(order, ['id', '_id']);
                  final status = textOf(order, ['status'], 'pending');

                  return Card(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailPage(prefs: widget.prefs, orderId: id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '#${id.length > 8 ? id.substring(0, 8) : id}',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(_orderSubtitle(order)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  AppFormatters.price(
                                    order['total_amount'] ??
                                        order['total'] ??
                                        order['total_price'] ??
                                        order['grand_total'],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Chip(
                                  label: Text(status),
                                  backgroundColor: OrderStatus.color(
                                    status,
                                  ).withOpacity(.18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

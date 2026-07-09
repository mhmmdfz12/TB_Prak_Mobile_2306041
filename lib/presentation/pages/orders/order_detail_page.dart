import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/formatters.dart';
import '../../../core/helpers/response_parser.dart';
import '../../../core/helpers/ui_helpers.dart';
import '../../../data/network/api_client.dart';
import 'order_status.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({
    super.key,
    required this.prefs,
    required this.orderId,
  });

  final SharedPreferences prefs;
  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Map<String, dynamic> _order = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final data = await ApiClient(
        widget.prefs,
      ).get('/orders/${widget.orderId}', auth: true);
      _order = mapFrom(data);
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = listFrom(_order['items'] ?? _order['order_items'] ?? []);
    final status = textOf(_order, ['status'], 'pending');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(status),
                    backgroundColor: OrderStatus.color(status).withOpacity(.18),
                  ),
                ),
                _InfoRow(
                  label: 'Alamat',
                  value: textOf(_order, ['shipping_address', 'address'], '-'),
                ),
                _InfoRow(
                  label: 'Catatan',
                  value: textOf(_order, ['notes', 'note'], '-'),
                ),
                _InfoRow(
                  label: 'Tanggal',
                  value: textOf(_order, ['created_at', 'createdAt'], '-'),
                ),
                const Divider(),
                ...items.map((item) {
                  final orderItem = Map<String, dynamic>.from(item);
                  final product = orderItem['product'] is Map
                      ? Map<String, dynamic>.from(orderItem['product'])
                      : orderItem;
                  final quantity = intOf(orderItem['quantity']);
                  final price = doubleOf(
                    orderItem['price'] ?? product['price'],
                  );

                  return ListTile(
                    title: Text(
                      textOf(orderItem, [
                        'product_name',
                        'name',
                        'title',
                      ], textOf(product, ['name', 'title'], 'Produk')),
                    ),
                    subtitle: Text('${AppFormatters.price(price)} x $quantity'),
                    trailing: Text(
                      AppFormatters.price(
                        orderItem['subtotal'] ?? price * quantity,
                      ),
                    ),
                  );
                }),
                const Divider(),
                _InfoRow(
                  label: 'Total',
                  value: AppFormatters.price(
                    _order['total_amount'] ??
                        _order['total'] ??
                        _order['total_price'] ??
                        _order['grand_total'],
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

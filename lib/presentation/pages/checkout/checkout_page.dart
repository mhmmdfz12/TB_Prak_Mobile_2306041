import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/ui_helpers.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/network/api_client.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.prefs, required this.onDone});

  final SharedPreferences prefs;
  final Future<void> Function() onDone;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _createOrder() async {
    if (_addressController.text.trim().length < 10) {
      showMessage(context, 'Alamat minimal 10 karakter');
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      'Buat pesanan sekarang?',
    );
    if (!confirmed) return;

    setState(() => _loading = true);
    try {
      await ApiClient(widget.prefs).post(
        '/orders',
        auth: true,
        body: {
          'shipping_address': _addressController.text.trim(),
          'address': _addressController.text.trim(),
          'notes': _noteController.text.trim(),
          'note': _noteController.text.trim(),
        },
      );
      await NotificationService.showOrderSuccess();
      await widget.onDone();

      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, 'Pesanan berhasil dibuat');
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Lengkapi data pengiriman',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Alamat Pengiriman',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Catatan opsional',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _createOrder,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Buat Pesanan'),
          ),
        ],
      ),
    );
  }
}

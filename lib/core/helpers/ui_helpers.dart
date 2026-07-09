import 'package:flutter/material.dart';

void showMessage(BuildContext context, Object message) {
  final cleanMessage = message.toString().replaceFirst('Exception: ', '');
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(cleanMessage)));
}

Future<bool> showConfirmDialog(BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya'),
            ),
          ],
        ),
      ) ??
      false;
}

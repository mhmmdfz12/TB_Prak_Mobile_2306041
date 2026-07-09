import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/response_parser.dart';
import '../../../core/helpers/ui_helpers.dart';
import '../../../data/network/api_client.dart';
import '../../app/app.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiClient(
        widget.prefs,
      ).get('/auth/profile', auth: true);
      final user = mapFrom(data);
      _nameController.text = textOf(user, ['name', 'full_name', 'fullname']);
      _phoneController.text = textOf(user, ['phone', 'phone_number', 'no_hp']);
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    try {
      await ApiClient(widget.prefs).put(
        '/auth/profile',
        auth: true,
        body: {
          // Backend hanya menerima field full_name dan phone untuk update profil.
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );

      await _loadProfile();
      if (mounted) showMessage(context, 'Profil berhasil diperbarui');
    } catch (e) {
      if (mounted) showMessage(context, e);
    }
  }

  Future<void> _logout() async {
    await widget.prefs.remove('token');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage(prefs: widget.prefs)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = UasCommerceApp.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: appState.darkMode,
                  onChanged: appState.setDarkMode,
                  title: const Text('Mode gelap'),
                  subtitle: const Text('Tema tersimpan di local storage'),
                ),
                FilledButton(
                  onPressed: _saveProfile,
                  child: const Text('Simpan Profil'),
                ),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
    );
  }
}

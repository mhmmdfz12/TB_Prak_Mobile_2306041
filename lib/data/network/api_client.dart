import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';

class ApiClient {
  ApiClient(this.prefs);

  final SharedPreferences prefs;

  String? get token => prefs.getString('token');

  Map<String, String> _headers({bool auth = false}) {
    return {
      'Content-Type': 'application/json',
      if (auth && token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {bool auth = false}) {
    return _request('GET', path, auth: auth);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _request('POST', path, body: body, auth: auth);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _request('PUT', path, body: body, auth: auth);
  }

  Future<dynamic> delete(String path, {bool auth = false}) {
    return _request('DELETE', path, auth: auth);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: _headers(auth: auth));
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers(auth: auth),
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers(auth: auth),
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers(auth: auth));
          break;
        default:
          throw Exception('Method API tidak valid');
      }
    } catch (_) {
      throw Exception(
        'API tidak dapat diakses. Pastikan backend berjalan di ${ApiConstants.baseUrl}',
      );
    }

    final data = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = data is Map
          ? data['message'] ?? data['error'] ?? 'Terjadi kesalahan'
          : 'Terjadi kesalahan';

      // Tampilkan detail validasi dari backend agar bug mudah dibaca saat testing.
      if (data is Map &&
          data['errors'] is List &&
          (data['errors'] as List).isNotEmpty) {
        final firstError = Map<String, dynamic>.from(
          (data['errors'] as List).first as Map,
        );
        message = firstError['message'] ?? message;
      }

      throw Exception(message.toString());
    }

    return data;
  }
}

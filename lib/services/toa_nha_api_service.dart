import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/toa_nha.dart';

class ToaNhaApiService {
  static String get _base => '${ApiConfig.baseUrl}${ApiConfig.viTriPath}';

  static Future<List<ToaNhaViTri>> getDanhSach() async {
    final uri = Uri.parse(_base);
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'ngrok-skip-browser-warning': 'true'},
    );
    if (response.statusCode != 200) {
      throw Exception('Loi ${response.statusCode}: ${response.body}');
    }
    final list = jsonDecode(response.body) as List;
    return list.map((e) => ToaNhaViTri.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<ToaNhaViTri> getById(int id) async {
    final uri = Uri.parse('$_base/$id');
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'ngrok-skip-browser-warning': 'true'},
    );
    if (response.statusCode == 404) throw Exception('Khong tim thay toa nha id=$id');
    if (response.statusCode != 200) {
      throw Exception('Loi ${response.statusCode}: ${response.body}');
    }
    return ToaNhaViTri.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ToaNhaViTri> ghiViTri(ToaNhaViTriRequest request) async {
    final uri = Uri.parse(_base);
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Loi ${response.statusCode}: ${response.body}');
    }
    return ToaNhaViTri.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ToaNhaViTri> capNhatViTri(int id, ToaNhaViTriUpdateRequest request) async {
    final uri = Uri.parse('$_base/$id');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 404) throw Exception('Khong tim thay toa nha id=$id');
    if (response.statusCode != 200) {
      throw Exception('Loi ${response.statusCode}: ${response.body}');
    }
    return ToaNhaViTri.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<void> xoaViTri(int id) async {
    final uri = Uri.parse('$_base/$id');
    final response = await http.delete(
      uri,
      headers: {'Accept': 'application/json', 'ngrok-skip-browser-warning': 'true'},
    );
    if (response.statusCode == 404) throw Exception('Khong tim thay toa nha id=$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Loi ${response.statusCode}: ${response.body}');
    }
  }
}

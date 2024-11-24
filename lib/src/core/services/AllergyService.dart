import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AllergyService {
  final String _baseUrl = 'http://192.168.1.68:8080';
  final _storage = FlutterSecureStorage();

  Future<String?> getUserIdFromToken() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'].toString();
    }
    return null;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer "$token"', 
    };
  }

  Future<Map<String, dynamic>> getAllergies() async {
    try {
      final userId = await getUserIdFromToken();
      if (userId == null) {
        return {'success': false, 'message': 'No se encontró el token'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/Allergy/ByUser/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> allergies = json.decode(response.body);
        if (allergies.isEmpty) {
          return {'success': true, 'message': '0 alergias', 'data': []};
        }
        return {'success': true, 'data': allergies};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Sesión expirada', 'sessionExpired': true};
      } else {
        return {'success': false, 'message': 'Error al obtener las alergias'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> createAllergy(String name) async {
    try {
      final userId = await getUserIdFromToken();
      if (userId == null) {
        return {'success': false, 'message': 'No se encontró el token'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/Allergy'),
        headers: await _getHeaders(),
        body: json.encode({
          'name': name,
          'UserId': int.parse(userId),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Alergia agregada correctamente'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Sesión expirada', 'sessionExpired': true};
      } else {
        return {'success': false, 'message': 'Error al crear la alergia'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_vaccine/src/core/services/AllergyService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VaccineService {
  final String _baseUrl = 'http://192.168.1.68:8080';
  final _storage = FlutterSecureStorage();
  final AllergyService service = AllergyService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer "$token"',
    };
  }

  Future<Map<String, dynamic>> getAvailableVaccines() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/Vaccine'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> vaccines = json.decode(response.body);
        return {'success': true, 'data': vaccines};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Sesión expirada', 'sessionExpired': true};
      } else {
        return {'success': false, 'message': 'Error al obtener las vacunas'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> registerVaccine({
    required int vaccineId,
    required String administeredLocation,
    required String administeredBy,
  }) async {
    try {
      final userId= await service.getUserIdFromToken();
      if (userId == null) {
        return {'success': false, 'message': 'No se encontró el token'};
      }
      final response = await http.post(
        Uri.parse('$_baseUrl/api/VaccineRecord'),
        headers: await _getHeaders(),
        body: json.encode({
          'UserId': int.parse(userId),
          'VaccineId': vaccineId,
          'AdministeredLocation': administeredLocation,
          'AdministeredBy': administeredBy,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Vacuna registrada exitosamente'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Sesión expirada', 'sessionExpired': true};
      } else {
        return {'success': false, 'message': 'Error al registrar la vacuna'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

   Future<Map<String, dynamic>> getVaccineRecords() async {
    try {
      final token = await _storage.read(key: 'token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No se encontró token de sesión',
          'sessionExpired': true
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/VaccineRecord/records-user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesión expirada',
          'sessionExpired': true
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'Registros obtenidos exitosamente'
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener los registros'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}'
      };
    }
  }
}
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:my_vaccine/src/core/services/AllergyService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyGroupService {
  final String apiUrl = 'http://192.168.1.68:8080/api/FamilyGroup/ByUser/';
  final _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getFamilyGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await _storage.read(key: 'token');
    final AllergyService service = AllergyService();

    final userIdd = await service.getUserIdFromToken();
    if(userIdd == null)return {'success': false, 'message': 'Service unavailable'};
    final userId= int.parse(userIdd);
    final response = await http.get(
      Uri.parse('$apiUrl$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer "$token"',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': json.decode(response.body)};
    } else if (response.statusCode == 401) {
      return {'success': false, 'sessionExpired': true, 'message': 'Session expired'};
    } else {
      return {'success': false, 'message': 'Service unavailable'};
    }
  }
}
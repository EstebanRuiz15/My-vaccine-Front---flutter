import 'package:flutter/material.dart';
import 'package:my_vaccine/src/feautures/screens/allergies_screen.dart';
import 'package:my_vaccine/src/feautures/screens/family_group_screen.dart';
import 'package:my_vaccine/src/feautures/screens/home_screen.dart';
import 'package:my_vaccine/src/feautures/screens/login_screen.dart';
import 'package:my_vaccine/src/feautures/screens/new_vaccine_screen.dart';
import 'package:my_vaccine/src/feautures/screens/profile.dart';
import 'package:my_vaccine/src/feautures/screens/register_screen.dart';
import 'package:my_vaccine/src/feautures/screens/vaccine_records_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String vaccineRecords = '/vaccine-records';
  static const String newVaccine = '/new-vaccine';
  static const String familyGroup = '/family-group';
  static const String allergies = '/allergies';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case vaccineRecords:
        return MaterialPageRoute(builder: (_) => VaccineRecordsScreen());
      case newVaccine:
        return MaterialPageRoute(builder: (_) => NewVaccineScreen());
      case familyGroup:
        return MaterialPageRoute(builder: (_) => FamilyGroupScreen());
      case allergies:
        return MaterialPageRoute(builder: (_) => AllergiesScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada'),
            ),
          ),
        );
    }
  }
}
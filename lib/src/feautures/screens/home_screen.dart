import 'package:flutter/material.dart';
import 'package:my_vaccine/src/routes/routes.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('My Vaccine'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(228, 21, 135, 228), 
                ),
                child: Column(
                  children: const [
                    Text(
                      '¡Bienvenido a My Vaccine!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '¿Qué quieres hacer hoy?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildOptionCard(
                      context,
                      'Registros de Vacunas',
                      'Consulta y gestiona tus registros de vacunación',
                      Icons.list_alt,
                      const Color.fromARGB(232, 14, 137, 238),
                      () => Navigator.pushNamed(context, AppRoutes.vaccineRecords),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      'Nueva Vacuna',
                      'Registra una nueva vacuna en tu historial',
                      Icons.add_circle,
                      Colors.green,
                      () => Navigator.pushNamed(context, AppRoutes.newVaccine),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      'Grupo Familiar',
                      'Administra los registros de tu familia',
                      Icons.family_restroom,
                      Colors.orange,
                      () => Navigator.pushNamed(context, AppRoutes.familyGroup),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      'Alergias',
                      'Gestiona tus registros de alergias',
                      Icons.warning_rounded,
                      Colors.red,
                      () => Navigator.pushNamed(context, AppRoutes.allergies),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(234, 24, 142, 238),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'My Vaccine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            'Perfil',
            Icons.person,
            AppRoutes.profile,
          ),
          _buildDrawerItem(
            context,
            'Inicio',
            Icons.home,
            AppRoutes.home,
          ),
          _buildDrawerItem(
            context,
            'Registros de Vacunas',
            Icons.list_alt,
            AppRoutes.vaccineRecords,
          ),
          _buildDrawerItem(
            context,
            'Nueva Vacuna',
            Icons.add_circle,
            AppRoutes.newVaccine,
          ),
          _buildDrawerItem(
            context,
            'Grupo Familiar',
            Icons.family_restroom,
            AppRoutes.familyGroup,
          ),
          _buildDrawerItem(
            context,
            'Alergias',
            Icons.warning_rounded,
            AppRoutes.allergies,
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            'Cerrar Sesión',
            Icons.exit_to_app,
            AppRoutes.login,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    String route
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (route == AppRoutes.login) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
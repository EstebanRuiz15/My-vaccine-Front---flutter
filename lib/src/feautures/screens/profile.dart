import 'package:flutter/material.dart';
import 'package:my_vaccine/src/core/services/GroupFamilyService.dart';
import 'package:my_vaccine/src/core/services/loginService.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final loginService _userService = loginService();
  final FamilyGroupService groupService = FamilyGroupService();
  Map<String, dynamic>? _userInfo;
  List<dynamic> _familyGroups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadFamilyGroups();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    final result = await _userService.getUserInfo();

    if (result['sessionExpired'] == true) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        _userInfo = result['data'];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadFamilyGroups() async {
    final result = await groupService.getFamilyGroup();

    if (result['sessionExpired'] == true) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        _familyGroups = result['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${_userInfo?['firstName'] ?? ''} ${_userInfo?['lastName'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          title: 'Información Personal',
                          children: [
                            _buildInfoRow('Nombre', _userInfo?['firstName'] ?? 'No disponible'),
                            _buildInfoRow('Apellido', _userInfo?['lastName'] ?? 'No disponible'),
                            _buildInfoRow('Tipo de Sangre', 'A+'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildFamilyGroupCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFamilyGroupCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.family_restroom, size: 24),
                SizedBox(width: 8),
                Text(
                  'Grupos Familiares',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (_familyGroups.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No perteneces a ningún grupo familiar',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              Column(
                children: _familyGroups.map<Widget>((group) {
                  // Convertimos el grupo a Map si no lo es
                  final Map<String, dynamic> groupData;
                  if (group is Map<String, dynamic>) {
                    groupData = group;
                  } else {
                    groupData = Map<String, dynamic>.from(group as Map);
                  }
                  return _buildFamilyGroupDetails(groupData);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyGroupDetails(Map<String, dynamic> group) {
    final List<dynamic> members = group['users'] ?? [];

    // Debug print para verificar los miembros
    print('Members: $members');

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Familia ${group['name']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Integrantes:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...members.map((member) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        member.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
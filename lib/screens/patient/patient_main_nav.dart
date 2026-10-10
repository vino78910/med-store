import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import 'patient_home_screen.dart';
import 'find_medicine_screen.dart';
import 'availability_alerts_screen.dart';
import 'patient_profile_screen.dart';

class PatientMainNav extends StatefulWidget {
  const PatientMainNav({super.key});

  @override
  State<PatientMainNav> createState() => _PatientMainNavState();
}

class _PatientMainNavState extends State<PatientMainNav> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      PatientHomeScreen(onNavigateTab: _onTabSelected),
      const FindMedicineScreen(),
      const AvailabilityAlertsScreen(),
      const PatientProfileScreen(),
    ];

    final titles = [
      'VitalMed Patient Home',
      'Find Medicine Nearby',
      'My Restock Alerts',
      'Patient Profile',
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: titles[_currentIndex],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Find Medicine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_rounded),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

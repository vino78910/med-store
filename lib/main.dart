import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'models/user_model.dart';
import 'screens/splash_screen.dart';
import 'screens/pharmacy/pharmacy_main_nav.dart';
import 'screens/patient/patient_main_nav.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const VitalMedApp(),
    ),
  );
}

class VitalMedApp extends StatelessWidget {
  const VitalMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    return MaterialApp(
      title: 'VitalMed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _resolveHomeScreen(user),
    );
  }

  Widget _resolveHomeScreen(UserModel? user) {
    if (user == null) {
      return const LoginScreen();
    }
    if (user.isPatient) {
      return const PatientMainNav();
    }
    return const PharmacyMainNav();
  }
}

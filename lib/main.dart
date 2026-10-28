import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Ensure this is imported
import 'package:path_provider/path_provider.dart'
    as path_provider; // Ensure this is imported

import 'firebase_options.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'models/scan_data.dart'; // Ensure this is imported (The Hive model)
import 'services/scan_history_service.dart'; // Import to access boxName

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- HIVE INITIALIZATION START ---
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(
    ScanDataAdapter(),
  ); // <--- Register the generated adapter
  // --- HIVE INITIALIZATION END ---
  await Hive.openBox<ScanData>(ScanHistoryService.boxName);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DermaScanApp());
}

class DermaScanApp extends StatelessWidget {
  const DermaScanApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenDisclaimer = prefs.getBool('hasSeenDisclaimer') ?? false;

    // Check Firebase authentication state
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → go to SignIn screen
      return const SignInScreen();
    } else if (!hasSeenDisclaimer) {
      // Logged in but hasn’t seen disclaimer → go to disclaimer
      return const DisclaimerScreen();
    } else {
      // Logged in and disclaimer seen → go to home
      return HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Derma Scan',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E8BC0), // Calm blue
        scaffoldBackgroundColor: const Color(
          0xFFF8FAFC,
        ), // Very light gray-white
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E8BC0), // Calm blue
          secondary: Color(0xFFB1D4E0), // Light blue
          surface: Color(0xFFFFFFFF), // White
          background: Color(0xFFF8FAFC), // Very light gray-white
          error: Color(0xFFE63946), // Soft red
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Color(0xFF0C4160), // Deep navy
          onSurface: Color(0xFF0C4160), // Deep navy
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E8BC0), // Calm blue
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E8BC0), // Calm blue
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2E8BC0), // Calm blue
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2E8BC0), // Calm blue
            side: const BorderSide(color: Color(0xFF2E8BC0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFB1D4E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFB1D4E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF2E8BC0), width: 2.0),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xFFE2F0F6), width: 1.0),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}

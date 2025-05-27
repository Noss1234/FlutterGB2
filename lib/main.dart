import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Removed: import 'package:shared_preferences/shared_preferences.dart';

import 'providers/plant_provider.dart';
// Removed: import 'screens/home_screen.dart';
// Removed: import 'screens/zone_overview_screen.dart';
// Removed: import 'screens/settings_screen.dart';
import 'screens/main_navigation_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Removed unused import
// import 'screens/zone_overview_screen.dart'; // Removed unused import as per analyzer
import 'services/pico_initializer.dart'; // Renamed import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializePicoService(); // initializeEspService to initializePicoService
  runApp(const MyGardenApp());
}

class MyGardenApp extends StatelessWidget {
  const MyGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlantProvider(),
      child: MaterialApp(
        title: 'MyGarden Controller',
        theme: ThemeData(
          primaryColor: Colors.green[600],
          scaffoldBackgroundColor: Colors.grey[200],
          appBarTheme: AppBarTheme( 
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            elevation: 1.0,
            titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          cardTheme: const CardTheme( // Corrected CardThemeData to CardTheme
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[500],
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))), // Added const and BorderRadius.all
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder( // Can be const if BorderSide is const
              borderRadius: const BorderRadius.all(Radius.circular(8.0)), // Added const
              borderSide: BorderSide(color: Colors.grey[400]!), // Cannot be const due to Colors.grey[400]!
            ),
            focusedBorder: OutlineInputBorder( // Can be const if BorderSide is const
              borderRadius: const BorderRadius.all(Radius.circular(8.0)), // Added const
              borderSide: BorderSide(color: Colors.green[600]!), // Cannot be const due to Colors.green[600]!
            ),
            filled: true,
            fillColor: Colors.white70,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          textTheme: TextTheme( // Can be const
            headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]), // Cannot be const
            titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]), // Cannot be const
            bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]), // Cannot be const
          ),
          iconTheme: IconThemeData( // Can be const
            color: Colors.green[600], // Cannot be const
          ),
        ),
        home: const MainNavigationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

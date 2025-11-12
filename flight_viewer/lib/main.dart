import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_tab_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/flight_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool>? _firstRun;

  @override
  void initState() {
    super.initState();
    _firstRun = _checkFirstRun();
  }

  Future<bool> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_done') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlightProvider()),
      ],
      child: MaterialApp(
        title: 'SkyScan Flight Viewer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            primary: const Color(0xFF1E88E5),
            secondary: const Color(0xFF64B5F6),
            surface: Colors.white,
            background: const Color(0xFFF5F5F5),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.black87),
          ),
          // cardTheme: 
          //  CardTheme(
          //   elevation: 2,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(12)),
          //   ),
          //   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   clipBehavior: Clip.antiAlias,
          //   shadowColor: Colors.black26,
          // ),


          
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
          textTheme: TextTheme(
            titleLarge: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            titleMedium: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            titleSmall: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            bodyLarge: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            bodySmall: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            labelLarge: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        home: FutureBuilder<bool>(
          future: _firstRun,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return snapshot.data! ? const OnboardingScreen() : const MainTabScreen();
          },
        ),
      ),
    );
  }
}

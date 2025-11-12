import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_tab_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/flight_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';

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
  Future<bool>? _authCheck;

  @override
  void initState() {
    super.initState();
    _firstRun = _checkFirstRun();
    _authCheck = _checkAuthStatus();
  }

  Future<bool> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_done') ?? false);
  }

  Future<bool> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');
    return token != null && userId != null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlightProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return MaterialApp(
            title: 'SkyScan Flight Viewer',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
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
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.dark,
                primary: const Color(0xFF64B5F6),
                secondary: const Color(0xFF1E88E5),
                surface: const Color(0xFF1E1E1E),
                background: const Color(0xFF121212),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Color(0xFF1E1E1E),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF2D2D2D),
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
                  color: Colors.white,
                ),
                titleMedium: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                titleSmall: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                bodyLarge: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                bodyMedium: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                bodySmall: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
                labelLarge: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              cardTheme: const CardThemeData(
                color: Color(0xFF1E1E1E),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            home: FutureBuilder<bool>(
              future: _firstRun,
              builder: (context, firstRunSnapshot) {
                if (!firstRunSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (firstRunSnapshot.data!) {
                  return const OnboardingScreen();
                }
                
                return FutureBuilder<bool>(
                  future: _authCheck,
                  builder: (context, authSnapshot) {
                    if (!authSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    return authSnapshot.data! ? const MainTabScreen() : const LoginScreen();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
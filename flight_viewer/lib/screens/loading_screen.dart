import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_loader.dart';
import '../../services/haptics_service.dart';

class LoadingScreen extends StatefulWidget {
  final String message;

  const LoadingScreen({super.key, this.message = 'Loading...'});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final HapticsService _hapticsService = HapticsService();

  @override
  void initState() {
    super.initState();
    // Trigger a light haptic feedback when loading starts
    _hapticsService.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: CustomLoader(
          message: widget.message,
          useIOSStyle: true,
        ),
      ),
    );
  }
}
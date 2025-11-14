import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'search_form_screen.dart';
import 'my_bookings_screen.dart';
import '../providers/theme_provider.dart';

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('SkyScan', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 14),
              Text('Find and manage your flights', style: TextStyle(fontSize: 14, color: Colors.grey),),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<ThemeProvider>(
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
            ),
          ],
          bottom: TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5) ?? Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3.0,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Search Flights'),
              Tab(text: 'My Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SearchFormScreen(),
            MyBookingsScreen(),
          ],
        ),
      ),
    );
  }
}
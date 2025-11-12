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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(46),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelPadding: const EdgeInsets.symmetric(vertical: 12),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Search Flights'),
                  Tab(text: 'My Bookings'),
                ],
              ),
            ),
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
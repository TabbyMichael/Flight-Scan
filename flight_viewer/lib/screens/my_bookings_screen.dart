import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider()..fetchBookings(),
      child: const _MyBookingsBody(),
    );
  }
}

class _MyBookingsBody extends StatelessWidget {
  const _MyBookingsBody();

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
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
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading bookings: ${bookingProvider.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => bookingProvider.fetchBookings(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : bookingProvider.bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.travel_explore, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('No bookings yet', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          const Text('Your confirmed trips will appear here.'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => bookingProvider.fetchBookings(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookingProvider.bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookingProvider.bookings[index];
                          final passenger = booking['passenger'] as Map<String, dynamic>;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Booking #${booking['pnr']}',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Chip(
                                        label: Text(booking['status'] ?? 'Confirmed'),
                                        backgroundColor: Colors.green.shade100,
                                        labelStyle: TextStyle(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${passenger['first_name']} ${passenger['last_name']}',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    passenger['email'] ?? '',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Flight ID: ${booking['flight_id']}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        '\$${(booking['total_price'] ?? 0).toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Booked on: ${_formatDate(booking['created_at'])}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
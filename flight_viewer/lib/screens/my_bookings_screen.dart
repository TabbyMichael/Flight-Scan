import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/theme_provider.dart';
import '../models/booking.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  static const String userEmail = 'user@example.com'; // In a real app, this would come from user authentication

  @override
  void initState() {
    super.initState();
    // Fetch bookings when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = context.read<BookingProvider>();
      bookingProvider.fetchBookings(userEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider(),
      child: _MyBookingsBody(userEmail: userEmail),
    );
  }
}

class _MyBookingsBody extends StatelessWidget {
  final String userEmail;

  const _MyBookingsBody({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BookingProvider>().fetchBookings(userEmail);
            },
          ),
        ],
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingProvider.error != null
              ? Center(child: Text('Error: ${bookingProvider.error}'))
              : bookingProvider.bookings.isEmpty
                  ? _buildEmptyState()
                  : _buildBookingsList(bookingProvider.bookings),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(booking: booking);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Confirmed',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Flight info (simplified)
            const Row(
              children: [
                Icon(Icons.flight_takeoff, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text('Flight Information'),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Passenger info
            const Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('Passenger'),
              ],
            ),
            const SizedBox(height: 4),
            Text('${booking.firstName} ${booking.lastName}'),
            
            const SizedBox(height: 8),
            
            // Price info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total'),
                Text(
                  '\$${booking.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Booking date
            Text(
              'Booked on ${_formatDate(booking.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
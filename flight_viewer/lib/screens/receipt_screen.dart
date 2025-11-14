import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import 'main_tab_screen.dart';

class ReceiptScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainTabScreen()),
                (route) => false,
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('PNR: ${receipt.pnr}'),
            Text('Booking ID: ${receipt.bookingId}'),
            const Divider(height: 32),
            
            // Flight Details
            const Text('Flight Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('${receipt.flightNumber} • ${receipt.departure} to ${receipt.arrival}'),
            Text('Departure: ${DateFormat('MMM d, y • h:mm a').format(receipt.departureTime)}'),
            
            // Passenger Details
            const SizedBox(height: 16),
            const Text('Passenger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(receipt.passengerName),
            Text(receipt.email),
            
            // Extras
            if (receipt.extras.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Extras', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ...receipt.extras.entries.map((e) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${e.key} x${e.value}'),
                ),
              ),
            ],
            
            // Total
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  '\$${receipt.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainTabScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

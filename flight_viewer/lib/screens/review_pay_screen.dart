import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ReviewPayScreen extends StatelessWidget {
  final double totalCost;
  final Map<String, int> selections;
  final String firstName;
  final String lastName;
  final String passport;
  final String email;

  const ReviewPayScreen({
    super.key,
    required this.totalCost,
    required this.selections,
    required this.firstName,
    required this.lastName,
    required this.passport,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Pay'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passenger', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('$firstName $lastName'),
            Text(passport),
            Text(email),
            const Divider(height: 32),
            Text('Extras', style: Theme.of(context).textTheme.titleMedium),
            ...selections.entries.map((e) => Text('${e.key}: x${e.value}')),
            const Spacer(),
            Text('Total: \$${totalCost.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Success'),
                      content: const Text('Booking confirmed!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.popUntil(context, (r) => r.isFirst);
                          },
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
                child: const Text('Pay & Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
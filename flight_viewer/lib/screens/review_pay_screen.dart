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
                icon: Icon(themeProvider.themeIcon),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Passenger', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('$firstName $lastName', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(passport, style: Theme.of(context).textTheme.bodyMedium),
                    Text(email, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Extras', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...selections.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: Theme.of(context).textTheme.bodyMedium),
                              Text('x${e.value}', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.titleMedium),
                        Text('\$${totalCost.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            )),
                      ],
                    ),
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
            ),
          ],
        ),
      ),
    );
  }
}
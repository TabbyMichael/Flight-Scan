import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../providers/extra_service_provider.dart';
import '../providers/theme_provider.dart';
import 'passenger_details_screen.dart';
import '../widgets/custom_loader.dart';

class SelectServicesScreen extends StatelessWidget {
  final Flight flight;
  const SelectServicesScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExtraServiceProvider()..fetchServices(),
      child: _SelectServicesBody(flight: flight),
    );
  }
}

class _SelectServicesBody extends StatelessWidget {
  final Flight flight;
  const _SelectServicesBody({required this.flight});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExtraServiceProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extra Services'),
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
      body: provider.isLoading
          ? const Center(
              child: CustomLoader(
                message: 'Loading services...',
                useIOSStyle: true,
              ),
            )
          : provider.error != null
              ? Center(child: Text('Error: ${provider.error}'))
              : _ServiceList(flight: flight),
      bottomNavigationBar: provider.isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PassengerDetailsScreen(
                        flight: flight,
                        totalCost: provider.totalCost,
                        selections: provider.selections,
                      ),
                    ),
                  );
                },
                child: Text('Next  (\$${provider.totalCost.toStringAsFixed(2)})'),
              ),
            ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  final Flight flight;
  const _ServiceList({required this.flight});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExtraServiceProvider>();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (ctx, idx) {
        final svc = provider.services[idx];
        final qty = provider.quantityFor(svc.id);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(svc.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(svc.description),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${svc.price.toStringAsFixed(2)} each'),
                    Row(
                      children: [
                        IconButton(
                          onPressed: qty > svc.minQuantity
                              ? () {
                                  provider.setQuantity(svc.id, qty - 1);
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$qty'),
                        IconButton(
                          onPressed: qty < svc.maxQuantity
                              ? () {
                                  provider.setQuantity(svc.id, qty + 1);
                                }
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: provider.services.length,
    );
  }
}
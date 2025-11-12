import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../providers/extra_service_provider.dart';
import '../providers/theme_provider.dart';
import 'passenger_details_screen.dart';

class SelectServicesScreen extends StatelessWidget {
  final Flight flight;
  const SelectServicesScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExtraServiceProvider()..fetchServices(),
      child: const _SelectServicesBody(),
    );
  }
}

class _SelectServicesBody extends StatelessWidget {
  const _SelectServicesBody();

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
                icon: Icon(themeProvider.themeIcon),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text('Error: ${provider.error}'))
              : _ServiceList(),
      bottomNavigationBar: provider.isLoading
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PassengerDetailsScreen(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(svc.name, style: Theme.of(context).textTheme.titleMedium),
                    Text('\$${svc.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 4),
                Text(svc.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Quantity', style: Theme.of(context).textTheme.bodyMedium),
                    Row(
                      children: [
                        IconButton(
                          onPressed: qty > svc.minQuantity
                              ? () => provider.setQuantity(svc.id, qty - 1)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$qty', style: Theme.of(context).textTheme.titleMedium),
                        ),
                        IconButton(
                          onPressed: qty < svc.maxQuantity
                              ? () => provider.setQuantity(svc.id, qty + 1)
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../models/extra_service.dart';
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
      child: _SelectServicesBody(flight: flight),
    );
  }
}

class _SelectServicesBody extends StatefulWidget {
  final Flight flight;
  const _SelectServicesBody({required this.flight});

  @override
  State<_SelectServicesBody> createState() => _SelectServicesBodyState();
}

class _SelectServicesBodyState extends State<_SelectServicesBody> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExtraServiceProvider>();
    final categories = _getServiceCategories(provider.services);
    
    // Calculate total cost (flight price + extras)
    final totalCost = widget.flight.price + provider.totalCost;
    
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
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text('Error: ${provider.error}'))
              : Column(
                  children: [
                    // Price Summary
                    _PriceSummary(
                      flightPrice: widget.flight.price,
                      extrasPrice: provider.totalCost,
                      totalCost: totalCost,
                    ),
                    // Category Filter
                    _CategoryFilter(
                      categories: categories,
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                    // Service List
                    Expanded(
                      child: _ServiceList(
                        services: provider.services,
                        selectedCategory: _selectedCategory,
                      ),
                    ),
                  ],
                ),
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
                        flight: widget.flight,
                        totalCost: totalCost, // Pass total cost including flight price
                        selections: provider.selections,
                      ),
                    ),
                  );
                },
                child: Text('Next  (\$${totalCost.toStringAsFixed(2)})'),
              ),
            ),
    );
  }

  List<String> _getServiceCategories(List<ExtraService> services) {
    final categories = <String>{'All'};
    for (final service in services) {
      categories.add(service.category);
    }
    return categories.toList()..sort();
  }
}

class _PriceSummary extends StatelessWidget {
  final double flightPrice;
  final double extrasPrice;
  final double totalCost;

  const _PriceSummary({
    required this.flightPrice,
    required this.extrasPrice,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Flight Price'),
                Text('\$${flightPrice.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Extras'),
                Text('\$${extrasPrice.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const _CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: isSelected ? null : Theme.of(context).cardColor,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  final List<ExtraService> services;
  final String selectedCategory;

  const _ServiceList({
    required this.services,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExtraServiceProvider>();
    
    // Filter services by category
    final filteredServices = selectedCategory == 'All'
        ? services
        : services.where((service) => service.category == selectedCategory).toList();
    
    if (filteredServices.isEmpty) {
      return const Center(
        child: Text('No services available in this category'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (ctx, idx) {
        final svc = filteredServices[idx];
        final qty = provider.quantityFor(svc.id);
        return _ServiceCard(service: svc, quantity: qty, context: ctx);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: filteredServices.length,
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ExtraService service;
  final int quantity;
  final BuildContext context;

  const _ServiceCard({
    required this.service,
    required this.quantity,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExtraServiceProvider>();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service header with icon and title
            Row(
              children: [
                _getServiceIcon(service.category, this.context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (service.isMandatory)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Required',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Service description
            if (service.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                service.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            
            // Price and quantity selector
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${service.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    if (service.minQuantity > 0)
                      Text(
                        'Min: ${service.minQuantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                  ],
                ),
                _QuantitySelector(
                  serviceId: service.id,
                  currentQuantity: quantity,
                  minQuantity: service.minQuantity,
                  maxQuantity: service.maxQuantity,
                  onChanged: (newQty) {
                    provider.setQuantity(service.id, newQty);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getServiceIcon(String category, BuildContext contextParam) {
    IconData iconData;
    Color iconColor;
    
    switch (category.toLowerCase()) {
      case 'baggage':
        iconData = Icons.luggage;
        iconColor = Colors.brown;
        break;
      case 'meal':
      case 'meals':
        iconData = Icons.restaurant;
        iconColor = Colors.green;
        break;
      case 'seat':
      case 'seats':
        iconData = Icons.airline_seat_recline_normal;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.miscellaneous_services;
        iconColor = Theme.of(contextParam).colorScheme.primary;
    }
    
    return Icon(iconData, color: iconColor, size: 32);
  }
}

class _QuantitySelector extends StatelessWidget {
  final String serviceId;
  final int currentQuantity;
  final int minQuantity;
  final int maxQuantity;
  final Function(int) onChanged;

  const _QuantitySelector({
    required this.serviceId,
    required this.currentQuantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minus button
        IconButton(
          onPressed: currentQuantity > minQuantity
              ? () => onChanged(currentQuantity - 1)
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          splashRadius: 20,
        ),
        
        // Quantity display
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '$currentQuantity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        
        // Plus button
        IconButton(
          onPressed: currentQuantity < maxQuantity
              ? () => onChanged(currentQuantity + 1)
              : null,
          icon: const Icon(Icons.add_circle_outline),
          splashRadius: 20,
        ),
      ],
    );
  }
}
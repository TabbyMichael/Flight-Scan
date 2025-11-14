import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/flight.dart';
import '../models/extra_service.dart';
import '../providers/extra_service_provider.dart';
import '../providers/theme_provider.dart';
import 'passenger_details_screen.dart';
import '../widgets/custom_loader.dart';
import '../utils/navigation_utils.dart';

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
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total price
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${provider.totalCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Next button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          NavigationUtils.navigateWithDelay(
                            context: context,
                            page: PassengerDetailsScreen(
                              flight: flight,
                              totalCost: provider.totalCost,
                              selections: provider.selections,
                            ),
                            message: 'Preparing passenger details...',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue to Passenger Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header with flight info
        _buildFlightInfoHeader(context, flight),
        const SizedBox(height: 16),
        // Services list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: provider.services.length,
            itemBuilder: (ctx, idx) {
              final svc = provider.services[idx];
              return _ServiceCard(service: svc, provider: provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFlightInfoHeader(BuildContext context, Flight flight) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${flight.airlineCode} ${flight.flightNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${flight.departureAirport} → ${flight.arrivalAirport}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatTime(flight.departureTime)} - ${_formatTime(flight.arrivalTime)}',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.flight_takeoff, size: 24, color: Color(0xFF1E88E5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _ServiceCard extends StatelessWidget {
  final ExtraService service;
  final ExtraServiceProvider provider;

  const _ServiceCard({
    required this.service,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final qty = provider.quantityFor(service.id);
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getServiceIcon(service.name),
                    color: const Color(0xFF1E88E5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Service details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price and quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${service.price.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                // Quantity selector
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: qty > service.minQuantity
                            ? () => provider.setQuantity(service.id, qty - 1)
                            : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: qty > service.minQuantity ? Colors.black87 : Colors.grey[400],
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: qty < service.maxQuantity
                            ? () => provider.setQuantity(service.id, qty + 1)
                            : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: qty < service.maxQuantity ? const Color(0xFF1E88E5) : Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'extra baggage':
        return Icons.luggage;
      case 'priority boarding':
        return Icons.airline_seat_recline_extra;
      case 'meal':
        return Icons.restaurant;
      case 'seat selection':
        return Icons.event_seat;
      case 'travel insurance':
        return Icons.health_and_safety;
      default:
        return Icons.help_outline;
    }
  }
}
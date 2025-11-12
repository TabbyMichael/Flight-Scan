import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import 'flight_detail_screen.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load flights when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlightProvider>().fetchFlights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkyScan Flights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              _openFilterSheet(context);
            },
          ),
        ],
      ),
      body: Consumer<FlightProvider>(
        builder: (context, flightProvider, _) {
          if (flightProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (flightProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading flights: ${flightProvider.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => flightProvider.fetchFlights(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (flightProvider.flights.isEmpty) {
            return const Center(
              child: Text('No flights found'),
            );
          }

          return ListView.builder(
            itemCount: flightProvider.flights.length,
            itemBuilder: (context, index) {
              final flight = flightProvider.flights[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '${flight.airlineCode} ${flight.flightNumber}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${flight.departureAirport} → ${flight.arrivalAirport}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatTime(flight.departureTime)} - ${_formatTime(flight.arrivalTime)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${flight.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${flight.stops} ${flight.stops == 1 ? 'stop' : 'stops'}' ,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlightDetailScreen(flight: flight),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    final provider = context.read<FlightProvider>();
    final priceRange = provider.getPriceRange();
    final airlines = provider.getUniqueAirlines();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FilterBottomSheet(
          currentMaxPrice: priceRange['max']!,
          currentMaxStops: 3,
          selectedAirlines: {},
          minPrice: priceRange['min']!,
          maxPrice: priceRange['max']!,
          allAirlines: airlines,
          onApply: ({double? maxPrice, int? maxStops, Set<String>? airlines}) {
            provider.applyFilters(
              maxPrice: maxPrice,
              maxStops: maxStops,
              airlineCodes: airlines,
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import '../providers/theme_provider.dart';
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
            padding: const EdgeInsets.all(16),
            itemCount: flightProvider.flights.length,
            itemBuilder: (context, index) {
              final flight = flightProvider.flights[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${flight.airlineCode} ${flight.flightNumber}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: flight.stops == 0 
                                ? Colors.green.shade100 
                                : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${flight.stops} ${flight.stops == 1 ? 'stop' : 'stops'}',
                              style: TextStyle(
                                color: flight.stops == 0 
                                  ? Colors.green.shade800 
                                  : Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flight.departureAirport,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                _formatTime(flight.departureTime),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.flight_takeoff,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                _formatDuration(flight.duration),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                flight.arrivalAirport,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                _formatTime(flight.arrivalTime),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price from',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '\$${flight.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FlightDetailScreen(flight: flight),
                                ),
                              );
                            },
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }
}
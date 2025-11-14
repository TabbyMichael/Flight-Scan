import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/theme_provider.dart';
import 'select_services_screen.dart';
import '../models/flight.dart';
import '../widgets/custom_loader.dart';
import '../utils/navigation_utils.dart';

class FlightDetailScreen extends StatelessWidget {
  final Flight flight;

  const FlightDetailScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flight Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
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
      body: Column(
        children: [
          // Flight summary card
          _buildFlightHeader(context),
          
          // Main content with tabs
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      labelColor: Theme.of(context).colorScheme.onSurface,
                      unselectedLabelColor: Theme.of(context).hintColor,
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      tabs: const [
                        Tab(text: 'Details'),
                        Tab(text: 'Services'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Details Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              _buildSegmentsList(context),
                              const SizedBox(height: 16),
                              _buildFlightDetails(context),
                            ],
                          ),
                        ),
                        
                        // Services Tab
                        _buildServicesTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom action bar
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildFlightHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Airline and flight number
          Row(
            children: [
              _buildAirlineLogo(flight.airlineCode),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${flight.airlineName} (${flight.airlineCode})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Flight ${flight.flightNumber} • ${flight.cabinClass.isNotEmpty ? flight.cabinClass : 'Economy'}' ,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${flight.stops} ${flight.stops == 1 ? 'Stop' : 'Stops'}' ,
                  style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Flight route and times
          Row(
            children: [
              // Departure
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(flight.departureTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flight.departureAirport,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.hintColor,
                      ),
                    ),
                    Text(
                      _formatDate(flight.departureTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Duration and stops
              Column(
                children: [
                  Text(
                    _formatDuration(flight.duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 1,
                    width: 60,
                    color: Colors.grey[300],
                    child: Row(
                      children: List.generate(6, (index) {
                        return Container(
                          width: 4,
                          height: 1,
                          color: Colors.white,
                          margin: const EdgeInsets.only(right: 4),
                        );
                      }),
                    ),
                  ),
                  const Icon(Icons.flight_takeoff, size: 16, color: Color(0xFF1E88E5)),
                ],
              ),
              
              // Arrival
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(flight.arrivalTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flight.arrivalAirport,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.hintColor,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      _formatDate(flight.arrivalTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAirlineLogo(String airlineCode) {
    // In a real app, we would fetch the airline logo URL from an API
    // For now, we'll use a placeholder
    final logoUrl = 'https://travelnext.works/api/airlines/$airlineCode.gif';
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          placeholder: (context, url) => const Icon(Icons.airline_stops, size: 24),
          errorWidget: (context, url, error) => const Icon(Icons.airline_stops, size: 24),
        ),
      ),
    );
  }

  Widget _buildFlightDetails(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flight Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Flight Number', '${flight.airlineCode}${flight.flightNumber}'),
            _buildDetailRow(context, 'Aircraft', 'Boeing 737-800'), // Would come from API
            _buildDetailRow(context, 'Cabin Class', flight.cabinClass.isEmpty ? 'Economy' : flight.cabinClass),
            _buildDetailRow(context, 'Distance', '1,235 km'), // Would come from API
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentsList(BuildContext context) {
    if (flight.segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flight Itinerary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...flight.segments.map((segment) => _buildSegmentItem(context, segment)),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem(BuildContext context, Segment segment) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Departure
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flight_takeoff, size: 16, color: Color(0xFF1E88E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(segment.departureTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      segment.departureAirport,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Duration and stop info
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 4, bottom: 4),
            child: Row(
              children: [
                Text(
                  '${segment.duration} min',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Non-stop',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Arrival
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flight_land, size: 16, color: Color(0xFF1E88E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(segment.arrivalTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      segment.arrivalAirport,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(BuildContext context) {
    // This would be populated with actual services in a real app
    final List<Map<String, dynamic>> services = [
      {
        'icon': Icons.luggage,
        'title': 'Extra Baggage',
        'description': 'Add up to 10kg extra luggage',
        'price': 25.0,
      },
      {
        'icon': Icons.airline_seat_recline_extra,
        'title': 'Extra Legroom',
        'description': 'Get more space to stretch out',
        'price': 35.0,
      },
      {
        'icon': Icons.restaurant,
        'title': 'In-flight Meal',
        'description': 'Pre-order your meal',
        'price': 15.0,
      },
      {
        'icon': Icons.airport_shuttle,
        'title': 'Airport Transfer',
        'description': 'Comfortable ride to/from airport',
        'price': 30.0,
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(service['icon'], size: 20, color: const Color(0xFF1E88E5)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        service['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${service['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Color(0xFF1E88E5)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
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
        child: Row(
          children: [
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${flight.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ],
            ),
            
            // Book button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: ElevatedButton(
                  onPressed: () {
                    NavigationUtils.navigateWithDelay(
                      context: context,
                      page: SelectServicesScreen(flight: flight),
                      message: 'Preparing booking...',
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
                    'Book Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('E, MMM d, yyyy').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} • ${_formatTime(dateTime)}';
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
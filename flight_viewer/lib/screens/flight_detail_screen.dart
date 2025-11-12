import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'select_services_screen.dart';
import '../models/flight.dart';

class FlightDetailScreen extends StatelessWidget {
  final Flight flight;

  const FlightDetailScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight ${flight.airlineCode}${flight.flightNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlightHeader(),
            const SizedBox(height: 24),
            _buildFlightDetails(),
            const SizedBox(height: 24),
            _buildSegmentsList(),
            const SizedBox(height: 24),
            _buildPriceSection(),
            const SizedBox(height: 24),
            _buildBookButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (BuildContext context) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${flight.departureAirport} → ${flight.arrivalAirport}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(flight.departureTime)} • ${_formatDuration(flight.duration)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Chip(
                      label: Text(
                        '${flight.stops} ${flight.stops == 1 ? 'Stop' : 'Stops'}' ,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Airline logo and name
                Row(
                  children: [
                    _buildAirlineLogo(flight.airlineCode),
                    const SizedBox(width: 12),
                    Text(
                      '${flight.airlineName} (${flight.airlineCode})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Flight ${flight.flightNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (flight.cabinClass.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Text(
                      flight.cabinClass,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
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

  Widget _buildFlightDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flight Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildDetailRow('Airline', '${flight.airlineName} (${flight.airlineCode})'),
            _buildDetailRow('Flight Number', flight.flightNumber),
            _buildDetailRow('Departure', _formatDateTime(flight.departureTime)),
            _buildDetailRow('Arrival', _formatDateTime(flight.arrivalTime)),
            _buildDetailRow('Duration', _formatDuration(flight.duration)),
            _buildDetailRow('Cabin Class', flight.cabinClass.isEmpty ? 'Economy' : flight.cabinClass),
            _buildDetailRow('Aircraft', 'Boeing 737-800'), // This would come from the API in a real app
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentsList() {
    if (flight.segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flight Segments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...flight.segments.map((segment) => _buildSegmentItem(segment)),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem(Segment segment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${segment.departureAirport} → ${segment.arrivalAirport}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_formatTime(segment.departureTime)} - ${_formatTime(segment.arrivalTime)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildAirlineLogo(segment.airlineCode),
              const SizedBox(width: 8),
              Text(
                '${segment.airlineName} (${segment.airlineCode}) • Flight ${segment.flightNumber} • ',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                _formatDuration(segment.duration),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Price'),
                Text(
                  '${flight.currency} ${flight.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
                    Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectServicesScreen(flight: flight),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Book Now',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}
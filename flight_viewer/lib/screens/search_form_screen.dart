import '../utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'loading_screen.dart';
import '../services/haptics_service.dart';

class SearchFormScreen extends StatefulWidget {
  const SearchFormScreen({super.key});

  @override
  State<SearchFormScreen> createState() => _SearchFormScreenState();
}

enum TripType { roundTrip, oneWay }

class _SearchFormScreenState extends State<SearchFormScreen> {
  final _origCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final HapticsService _hapticsService = HapticsService();
  DateTime? _depDate;
  DateTime? _retDate;
  int _passengers = 1;
  TripType _tripType = TripType.oneWay; // Changed default to oneWay for simplicity

  Future<void> _pickDate({required bool isDeparture}) async {
    final now = DateTime.now();
    final initial = isDeparture ? _depDate ?? now : _retDate ?? now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _depDate = picked;
          if (_tripType == TripType.roundTrip && (_retDate == null || _retDate!.isBefore(picked))) {
            _retDate = picked.add(const Duration(days: 1));
          }
        } else {
          _retDate = picked;
        }
      });
    }
  }

  void _search() async {
    final provider = context.read<FlightProvider>();
    
    // Trigger haptic feedback when search begins
    _hapticsService.selection();
    
    try {
      // Perform search with form data
      await provider.searchFlights(
        origin: _origCtrl.text.isNotEmpty ? _origCtrl.text : null,
        destination: _destCtrl.text.isNotEmpty ? _destCtrl.text : null,
        departureDate: _depDate,
      );
      
      if (mounted) {
        // Trigger success haptic feedback
        _hapticsService.success();
        
        // Navigate to home screen with loading
        await NavigationUtils.navigateAndReplaceWithDelay(
          context: context,
          page: const HomeScreen(),
          message: 'Loading search results...',
        );
      }
    } catch (e) {
      if (mounted) {
        // Trigger error haptic feedback
        _hapticsService.error();
        
        // Go back to the search form
        Navigator.pop(context);
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Search Error'),
              content: Text('Failed to search flights: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Search Flights', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Find the best flights for your journey', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Radio<TripType>(
                value: TripType.roundTrip,
                groupValue: _tripType,
                onChanged: (v) => setState(() => _tripType = v!),
              ),
              const Text('Round Trip'),
              const SizedBox(width: 16),
              Radio<TripType>(
                value: TripType.oneWay,
                groupValue: _tripType,
                onChanged: (v) => setState(() => _tripType = v!),
              ),
              const Text('One Way'),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _origCtrl,
            decoration: const InputDecoration(
              labelText: 'From',
              hintText: 'e.g., JFK',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _destCtrl,
            decoration: const InputDecoration(
              labelText: 'To',
              hintText: 'e.g., LAX',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(isDeparture: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Departure Date',
                    ),
                    child: Text(_depDate == null ? 'Select date' : DateFormat.yMMMd().format(_depDate!)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_tripType == TripType.roundTrip)
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(isDeparture: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Return Date',
                      ),
                      child: Text(_retDate == null ? 'Select date' : DateFormat.yMMMd().format(_retDate!)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: _passengers,
            decoration: const InputDecoration(labelText: 'Passengers'),
            items: List.generate(6, (i) => i + 1)
                .map((n) => DropdownMenuItem(value: n, child: Text('$n Passenger${n > 1 ? 's' : ''}')))
                .toList(),
            onChanged: (v) => setState(() => _passengers = v!),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Text('Search Flights'),
            ),
          ),
        ],
      ),
    );
  }
}
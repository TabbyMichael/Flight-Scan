import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';

class SearchFormScreen extends StatefulWidget {
  const SearchFormScreen({super.key});

  @override
  State<SearchFormScreen> createState() => _SearchFormScreenState();
}

enum TripType { roundTrip, oneWay }

class _SearchFormScreenState extends State<SearchFormScreen> {
  final _origCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  DateTime? _depDate;
  DateTime? _retDate;
  int _passengers = 1;
  TripType _tripType = TripType.roundTrip;

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

  void _search() {
    final provider = context.read<FlightProvider>();
    provider.fetchFlights(); // For now, simply reload all flights
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<TripType>(
                      title: const Text('Round Trip'),
                      value: TripType.roundTrip,
                      groupValue: _tripType,
                      onChanged: (v) => setState(() => _tripType = v!),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<TripType>(
                      title: const Text('One Way'),
                      value: TripType.oneWay,
                      groupValue: _tripType,
                      onChanged: (v) => setState(() => _tripType = v!),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _origCtrl,
            decoration: InputDecoration(
              labelText: 'From',
              prefixIcon: const Icon(Icons.flight_takeoff),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destCtrl,
            decoration: InputDecoration(
              labelText: 'To',
              prefixIcon: const Icon(Icons.flight_land),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(text: _depDate == null ? '' : DateFormat.yMMMd().format(_depDate!)),
                  decoration: InputDecoration(
                    labelText: 'Departure Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () => _pickDate(isDeparture: true),
                ),
              ),
              const SizedBox(width: 12),
              if (_tripType == TripType.roundTrip)
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: _retDate == null ? '' : DateFormat.yMMMd().format(_retDate!)),
                    decoration: InputDecoration(
                      labelText: 'Return Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () => _pickDate(isDeparture: false),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _passengers,
            decoration: InputDecoration(
              labelText: 'Passengers',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: List.generate(6, (i) => i + 1)
                .map((n) => DropdownMenuItem(
                      value: n, 
                      child: Text('$n Passenger${n > 1 ? 's' : ''}'),
                    ))
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
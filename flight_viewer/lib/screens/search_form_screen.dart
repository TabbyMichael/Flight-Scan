import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
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
          Text('Search Flights', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Find the best flights for your journey', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
          TextField(
            controller: _origCtrl,
            decoration: const InputDecoration(labelText: 'From'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destCtrl,
            decoration: const InputDecoration(labelText: 'To'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(isDeparture: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Departure Date'),
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
                      decoration: const InputDecoration(labelText: 'Return Date'),
                      child: Text(_retDate == null ? 'Select date' : DateFormat.yMMMd().format(_retDate!)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _passengers,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../providers/theme_provider.dart';
import 'review_pay_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final Flight flight;
  final double totalCost;
  final Map<String, int> selections;
  const PassengerDetailsScreen({
    super.key,
    required this.flight,
    required this.totalCost,
    required this.selections,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _passport = '';
  String _email = '';

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPayScreen(
          flight: widget.flight,
          totalCost: widget.totalCost,
          selections: widget.selections,
          firstName: _firstName,
          lastName: _lastName,
          passport: _passport,
          email: _email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Details'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _firstName = v!,
                onChanged: (_) => {},
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _lastName = v!,
                onChanged: (_) => {},
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Passport Number'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _passport = v!,
                onChanged: (_) => {},
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
                onSaved: (v) => _email = v!,
                onChanged: (_) => {},
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _next,
                child: const Text('Review & Pay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
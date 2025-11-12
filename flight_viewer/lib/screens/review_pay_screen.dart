import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import 'booking_confirmation_screen.dart';

class ReviewPayScreen extends StatefulWidget {
  final double totalCost;
  final Map<String, int> selections;
  final String firstName;
  final String lastName;
  final String passport;
  final String email;
  final String flightId;

  const ReviewPayScreen({
    super.key,
    required this.totalCost,
    required this.selections,
    required this.firstName,
    required this.lastName,
    required this.passport,
    required this.email,
    required this.flightId,
  });

  @override
  State<ReviewPayScreen> createState() => _ReviewPayScreenState();
}

class _ReviewPayScreenState extends State<ReviewPayScreen> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  bool _processing = false;

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _processing = true;
    });

    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Create booking through API
      final apiService = ApiService();
      final bookingData = await apiService.createBooking(
        flightId: widget.flightId,
        firstName: widget.firstName,
        lastName: widget.lastName,
        email: widget.email,
        passport: widget.passport,
        extras: widget.selections,
        totalPrice: widget.totalCost,
      );
      
      if (mounted) {
        // Navigate to booking confirmation screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(bookingData: bookingData),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Payment Failed'),
            content: Text('Failed to process payment: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Pay'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passenger Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('${widget.firstName} ${widget.lastName}'),
              Text(widget.passport),
              Text(widget.email),
              const Divider(height: 32),
              Text('Selected Extras', style: Theme.of(context).textTheme.titleMedium),
              ...widget.selections.entries.map((e) => Text('${e.key}: x${e.value}')),
              const Divider(height: 32),
              Text('Payment Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.length < 16) {
                    return 'Invalid card number';
                  }
                  return null;
                },
                onSaved: (value) => _cardNumber = value!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                      ),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
                          return 'Invalid date format';
                        }
                        return null;
                      },
                      onSaved: (value) => _expiryDate = value!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVV';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                      onSaved: (value) => _cvv = value!,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text('Total: \$${widget.totalCost.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processing ? null : _processPayment,
                  child: _processing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Pay & Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
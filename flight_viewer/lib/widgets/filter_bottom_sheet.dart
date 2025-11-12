import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final double currentMaxPrice;
  final int currentMaxStops;
  final Set<String> selectedAirlines;
  final double minPrice;
  final double maxPrice;
  final List<String> allAirlines;
  final void Function({double? maxPrice, int? maxStops, Set<String>? airlines}) onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentMaxPrice,
    required this.currentMaxStops,
    required this.selectedAirlines,
    required this.minPrice,
    required this.maxPrice,
    required this.allAirlines,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _price;
  late int _stops;
  late Set<String> _airlines;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _price = widget.currentMaxPrice;
    _stops = widget.currentMaxStops;
    _airlines = {...widget.selectedAirlines};
    _priceController = TextEditingController(text: _price.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Flights', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPriceFilter(),
          const SizedBox(height: 24),
          _buildStopsFilter(),
          const SizedBox(height: 24),
          _buildAirlinesFilter(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Maximum Price', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${widget.minPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
            Text('\$${_price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium),
            Text('\$${widget.maxPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(
          min: widget.minPrice,
          max: widget.maxPrice,
          divisions: (widget.maxPrice - widget.minPrice).toInt(),
          value: _price,
          label: '\$${_price.toStringAsFixed(0)}',
          onChanged: (value) {
            setState(() {
              _price = value;
              _priceController.text = _price.toStringAsFixed(0);
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max Price',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price != null && price >= widget.minPrice && price <= widget.maxPrice) {
                      setState(() => _price = price);
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _price = widget.maxPrice;
                  _priceController.text = _price.toStringAsFixed(0);
                });
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStopsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Maximum Stops', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: Theme.of(context).textTheme.bodySmall),
            Text('$_stops', style: Theme.of(context).textTheme.titleMedium),
            Text('3', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(
          min: 0,
          max: 3,
          divisions: 3,
          value: _stops.toDouble(),
          label: '$_stops',
          onChanged: (value) => setState(() => _stops = value.toInt()),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return ChoiceChip(
              label: Text('$index'),
              selected: _stops == index,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _stops = index);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).cardTheme.color,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAirlinesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Airlines', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (widget.allAirlines.isEmpty)
          const Text('No airlines available', style: TextStyle(color: Colors.grey))
        else
          SizedBox(
            height: 150,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.allAirlines.length,
              itemBuilder: (context, index) {
                final code = widget.allAirlines[index];
                final selected = _airlines.contains(code);
                return FilterChip(
                  label: Text(code),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _airlines.remove(code);
                      } else {
                        _airlines.add(code);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  checkmarkColor: Colors.white,
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _airlines.clear()),
              child: const Text('Clear All'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => setState(() => _airlines = {...widget.allAirlines.toSet()}),
              child: const Text('Select All'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            // Reset all filters
            setState(() {
              _price = widget.maxPrice;
              _stops = 3;
              _airlines.clear();
              _priceController.text = _price.toStringAsFixed(0);
            });
          },
          child: const Text('Reset All'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            widget.onApply(maxPrice: _price, maxStops: _stops, airlines: _airlines);
            Navigator.pop(context);
          },
          child: const Text('Apply Filters'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}
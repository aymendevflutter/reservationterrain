import 'package:flutter/material.dart';
import '../../models/filter_model.dart';
import '../../core/constants/tunisia_constants.dart';

class FilterScreen extends StatefulWidget {
  final FilterModel? initialFilters;

  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterModel _filters;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final List<String> _days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  String? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters ?? FilterModel();
    _minPriceController.text = _filters.minPrice?.toString() ?? '';
    _maxPriceController.text = _filters.maxPrice?.toString() ?? '';
    _selectedDay = _filters.selectedDay;
    _startTime = _filters.startTime;
    _endTime = _filters.endTime;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtres'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _filters);
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _filters.wilaya,
            decoration: const InputDecoration(
              labelText: 'Wilaya',
              border: OutlineInputBorder(),
            ),
            items: TunisiaConstants.wilayas.map((wilaya) {
              return DropdownMenuItem(
                value: wilaya,
                child: Text(wilaya),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(wilaya: value);
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _filters.type,
            decoration: const InputDecoration(
              labelText: 'Type de terrain',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Football', child: Text('Football')),
              DropdownMenuItem(value: 'Basketball', child: Text('Basketball')),
              DropdownMenuItem(value: 'Tennis', child: Text('Tennis')),
              DropdownMenuItem(value: 'Volleyball', child: Text('Volleyball')),
              DropdownMenuItem(value: 'Handball', child: Text('Handball')),
              DropdownMenuItem(value: 'Rugby', child: Text('Rugby')),
            ],
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(type: value);
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix min (TND)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(
                        minPrice: double.tryParse(value),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maxPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix max (TND)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(
                        maxPrice: double.tryParse(value),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Équipements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Parking'),
            value: _filters.hasParking ?? false,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(hasParking: value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Éclairage'),
            value: _filters.hasLighting ?? false,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(hasLighting: value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Douches'),
            value: _filters.hasShowers ?? false,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(hasShowers: value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Vestiaires'),
            value: _filters.hasChangingRooms ?? false,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(hasChangingRooms: value);
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Jour et heure',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Jour'),
            subtitle: Text(_selectedDay ?? 'Sélectionner un jour'),
            trailing: DropdownButton<String>(
              value: _selectedDay,
              hint: const Text('Jour'),
              items: _days
                  .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedDay = val),
            ),
          ),
          ListTile(
            title: const Text('Heure de début'),
            subtitle: Text(_startTime != null
                ? _startTime!.format(context)
                : 'Sélectionner'),
            trailing: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _startTime ?? TimeOfDay(hour: 8, minute: 0),
                );
                if (picked != null) setState(() => _startTime = picked);
              },
            ),
          ),
          ListTile(
            title: const Text('Heure de fin'),
            subtitle: Text(
                _endTime != null ? _endTime!.format(context) : 'Sélectionner'),
            trailing: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _endTime ?? TimeOfDay(hour: 22, minute: 0),
                );
                if (picked != null) setState(() => _endTime = picked);
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    final newFilters = _filters.copyWith(
                      selectedDay: _selectedDay,
                      startTime: _startTime,
                      endTime: _endTime,
                    );
                    Navigator.of(context).pop(newFilters);
                  },
                  child: const Text('Appliquer'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Clear filters
                    setState(() {
                      _selectedDay = null;
                      _startTime = null;
                      _endTime = null;
                    });
                    final cleared = _filters.copyWith(
                      selectedDay: null,
                      startTime: null,
                      endTime: null,
                    );
                    Navigator.of(context).pop(cleared);
                  },
                  child: const Text('Réinitialiser'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

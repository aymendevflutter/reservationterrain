import 'package:flutter/material.dart';
import '../models/filter_model.dart';

class FilterScreen extends StatefulWidget {
  final FilterModel initialFilters;
  final Function(FilterModel) onApplyFilters;

  const FilterScreen({
    Key? key,
    required this.initialFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterModel _filters;
  final _formKey = GlobalKey<FormState>();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxDistanceController = TextEditingController();

  final List<String> _fieldTypes = [
    'Football',
    'Basketball',
    'Tennis',
    'Volleyball',
    'Handball',
    'Rugby',
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _minPriceController.text = _filters.minPrice?.toString() ?? '';
    _maxPriceController.text = _filters.maxPrice?.toString() ?? '';
    _locationController.text = _filters.location ?? '';
    _maxDistanceController.text = _filters.maxDistance?.toString() ?? '';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _locationController.dispose();
    _maxDistanceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    if (_formKey.currentState!.validate()) {
      final updatedFilters = _filters.copyWith(
        minPrice: double.tryParse(_minPriceController.text),
        maxPrice: double.tryParse(_maxPriceController.text),
        location: _locationController.text,
        maxDistance: double.tryParse(_maxDistanceController.text),
      );
      widget.onApplyFilters(updatedFilters);
      Navigator.pop(context);
    }
  }

  void _resetFilters() {
    setState(() {
      _filters = FilterModel();
      _minPriceController.clear();
      _maxPriceController.clear();
      _locationController.clear();
      _maxDistanceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filtres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Réinitialiser'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Prix par heure (TND)',
                icon: Icons.attach_money,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPriceField(
                        controller: _minPriceController,
                        label: 'Min',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPriceField(
                        controller: _maxPriceController,
                        label: 'Max',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Type de terrain',
                icon: Icons.sports_soccer,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _fieldTypes.map((type) {
                    final isSelected = _filters.type == type;
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: theme.primaryColor.withOpacity(0.2),
                      checkmarkColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? theme.primaryColor : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _filters = _filters.copyWith(
                            type: selected ? type : null,
                          );
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Localisation',
                icon: Icons.location_on,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Ville ou quartier',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxDistanceController,
                      decoration: InputDecoration(
                        labelText: 'Distance maximale (km)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.directions_walk),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final number = double.tryParse(value);
                          if (number == null || number < 0) {
                            return 'Distance invalide';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Équipements',
                icon: Icons.settings,
                child: Column(
                  children: [
                    _buildEquipmentSwitch(
                      title: 'Parking',
                      subtitle: 'Espace de stationnement disponible',
                      value: _filters.hasParking ?? false,
                      icon: Icons.local_parking,
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(hasParking: value);
                        });
                      },
                    ),
                    _buildEquipmentSwitch(
                      title: 'Éclairage',
                      subtitle: 'Terrain éclairé pour jouer la nuit',
                      value: _filters.hasLighting ?? false,
                      icon: Icons.lightbulb,
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(hasLighting: value);
                        });
                      },
                    ),
                    _buildEquipmentSwitch(
                      title: 'Douches',
                      subtitle: 'Installations de douche disponibles',
                      value: _filters.hasShowers ?? false,
                      icon: Icons.shower,
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(hasShowers: value);
                        });
                      },
                    ),
                    _buildEquipmentSwitch(
                      title: 'Vestiaires',
                      subtitle: 'Vestiaires pour se changer',
                      value: _filters.hasChangingRooms ?? false,
                      icon: Icons.dry_cleaning,
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(hasChangingRooms: value);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null || number < 0) {
            return 'Prix invalide';
          }
        }
        return null;
      },
    );
  }

  Widget _buildEquipmentSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

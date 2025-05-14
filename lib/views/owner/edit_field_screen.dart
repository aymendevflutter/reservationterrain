import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/field_model.dart';
import '../../providers/field_provider.dart';
import 'package:latlong2/latlong.dart';

class EditFieldScreen extends StatefulWidget {
  final FieldModel field;

  const EditFieldScreen({
    Key? key,
    required this.field,
  }) : super(key: key);

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _wilayaController;
  late TextEditingController _priceController;
  late TextEditingController _refereePriceController;
  late TextEditingController _maxPlayersController;

  bool _hasParking = false;
  bool _hasLighting = false;
  bool _hasShowers = false;
  bool _hasChangingRooms = false;
  bool _hasBuffet = false;
  bool _hasBalls = false;
  bool _hasJerseys = false;
  bool _hasReferee = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field.name);
    _descriptionController =
        TextEditingController(text: widget.field.description);
    _addressController = TextEditingController(text: widget.field.address);
    _wilayaController = TextEditingController(text: widget.field.wilaya);
    _priceController =
        TextEditingController(text: widget.field.pricePerHour.toString());
    _refereePriceController =
        TextEditingController(text: widget.field.refereePrice.toString());
    _maxPlayersController =
        TextEditingController(text: widget.field.maxPlayers.toString());

    _hasParking = widget.field.hasParking;
    _hasLighting = widget.field.hasLighting;
    _hasShowers = widget.field.hasShowers;
    _hasChangingRooms = widget.field.hasChangingRooms;
    _hasBuffet = widget.field.hasBuffet;
    _hasBalls = widget.field.hasBalls;
    _hasJerseys = widget.field.hasJerseys;
    _hasReferee = widget.field.hasReferee;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _wilayaController.dispose();
    _priceController.dispose();
    _refereePriceController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }

  Future<void> _updateField() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedField = widget.field.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        wilaya: _wilayaController.text.trim(),
        pricePerHour: double.parse(_priceController.text),
        refereePrice: double.parse(_refereePriceController.text),
        maxPlayers: int.parse(_maxPlayersController.text),
        hasParking: _hasParking,
        hasLighting: _hasLighting,
        hasShowers: _hasShowers,
        hasChangingRooms: _hasChangingRooms,
        hasBuffet: _hasBuffet,
        hasBalls: _hasBalls,
        hasJerseys: _hasJerseys,
        hasReferee: _hasReferee,
        updatedAt: DateTime.now(),
      );

      await context.read<FieldProvider>().updateField(updatedField);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terrain mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le terrain'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du terrain',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du terrain';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wilayaController,
                decoration: const InputDecoration(
                  labelText: 'Wilaya',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la wilaya';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix par heure (TND)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _refereePriceController,
                decoration: const InputDecoration(
                  labelText: 'Prix de l\'arbitre (TND)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix de l\'arbitre';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxPlayersController,
                decoration: const InputDecoration(
                  labelText: 'Nombre maximum de joueurs',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de joueurs';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Équipements disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Parking'),
                value: _hasParking,
                onChanged: (value) => setState(() => _hasParking = value),
              ),
              SwitchListTile(
                title: const Text('Éclairage'),
                value: _hasLighting,
                onChanged: (value) => setState(() => _hasLighting = value),
              ),
              SwitchListTile(
                title: const Text('Douches'),
                value: _hasShowers,
                onChanged: (value) => setState(() => _hasShowers = value),
              ),
              SwitchListTile(
                title: const Text('Vestiaires'),
                value: _hasChangingRooms,
                onChanged: (value) => setState(() => _hasChangingRooms = value),
              ),
              SwitchListTile(
                title: const Text('Buffet'),
                value: _hasBuffet,
                onChanged: (value) => setState(() => _hasBuffet = value),
              ),
              SwitchListTile(
                title: const Text('Ballons disponibles'),
                value: _hasBalls,
                onChanged: (value) => setState(() => _hasBalls = value),
              ),
              SwitchListTile(
                title: const Text('Maillots disponibles'),
                value: _hasJerseys,
                onChanged: (value) => setState(() => _hasJerseys = value),
              ),
              SwitchListTile(
                title: const Text('Service d\'arbitre'),
                value: _hasReferee,
                onChanged: (value) => setState(() => _hasReferee = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateField,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Mettre à jour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

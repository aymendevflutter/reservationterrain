import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../services/auth_service.dart';
import '../../models/field_model.dart';
import '../../widgets/map_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/field_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/tunisia_constants.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _refereePriceController = TextEditingController();
  List<String> _images = [];
  bool _isLoading = false;
  LatLng? _selectedLocation;
  String _selectedWilaya = TunisiaConstants.wilayas.first;
  String _selectedType = 'Football';
  TimeOfDay _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 22, minute: 0);
  bool _hasParking = false;
  bool _hasLighting = false;
  bool _hasShowers = false;
  bool _hasChangingRooms = false;
  bool _hasBuffet = false;
  bool _hasBalls = false;
  bool _hasJerseys = false;
  int _maxPlayers = 10;
  bool _hasReferee = false;

  final List<String> _fieldTypes = [
    'Football',
    'Basketball',
    'Tennis',
    'Volleyball',
    'Handball',
    'Rugby',
  ];

  final Map<String, Map<String, TimeOfDay>?> _customDayHours = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
    'Sunday': null,
  };
  final Set<String> _closedDays = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    _refereePriceController.dispose();
    super.dispose();
  }

  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      setState(() {
        _images.add(url);
        _imageUrlController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Veuillez entrer une URL valide commençant par http:// ou https://'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _configureDay(String day) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configurer $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Fermer ce jour'),
              onTap: () => Navigator.pop(context, 'close'),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Définir des horaires personnalisés'),
              onTap: () => Navigator.pop(context, 'open'),
            ),
          ],
        ),
      ),
    );
    if (result == 'close') {
      setState(() {
        _closedDays.add(day);
        _customDayHours[day] = null;
      });
    } else if (result == 'open') {
      final opening = await showTimePicker(
        context: context,
        initialTime: _openingTime,
      );
      if (opening == null) return;
      final closing = await showTimePicker(
        context: context,
        initialTime: _closingTime,
      );
      if (closing == null) return;
      setState(() {
        _closedDays.remove(day);
        _customDayHours[day] = {
          'opening': opening,
          'closing': closing,
        };
      });
    }
  }

  Widget _buildWeeklyHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horaires d\'ouverture hebdomadaires',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._customDayHours.keys.map((day) {
          final isClosed = _closedDays.contains(day);
          final custom = _customDayHours[day];
          return Card(
            child: ListTile(
              title: Text(day),
              subtitle: isClosed
                  ? const Text('Fermé')
                  : custom != null
                      ? Text(
                          'Ouvert: ${custom['opening']!.format(context)} - ${custom['closing']!.format(context)}')
                      : Text(
                          'Ouvert: ${_openingTime.format(context)} - ${_closingTime.format(context)} (par défaut)'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _configureDay(day),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un terrain'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du terrain',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
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
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix par heure (TND)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
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
                    return 'Veuillez entrer une adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedWilaya,
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
                  if (value != null) {
                    setState(() => _selectedWilaya = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de l\'image',
                        hintText: 'https://example.com/image.jpg',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addImageUrl,
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _images[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Sélectionnez l\'emplacement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              MapPicker(
                initialLocation: _selectedLocation,
                onLocationSelected: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Type de terrain',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _fieldTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
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
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3,
                children: [
                  SwitchListTile(
                    title: const Text('Parking'),
                    value: _hasParking,
                    onChanged: (value) {
                      setState(() => _hasParking = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Éclairage'),
                    value: _hasLighting,
                    onChanged: (value) {
                      setState(() => _hasLighting = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Douches'),
                    value: _hasShowers,
                    onChanged: (value) {
                      setState(() => _hasShowers = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Vestiaires'),
                    value: _hasChangingRooms,
                    onChanged: (value) {
                      setState(() => _hasChangingRooms = value);
                    },
                  ),
                  TextFormField(
                    initialValue: '10',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de joueurs',
                      prefixIcon: Icon(Icons.people),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _maxPlayers = int.tryParse(value) ?? 10;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Buffet'),
                    value: _hasBuffet,
                    onChanged: (value) {
                      setState(() => _hasBuffet = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Ballons'),
                    value: _hasBalls,
                    onChanged: (value) {
                      setState(() => _hasBalls = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Maillots'),
                    value: _hasJerseys,
                    onChanged: (value) {
                      setState(() => _hasJerseys = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Operating Hours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Opening Time'),
                      subtitle: Text(_openingTime.format(context)),
                      onTap: () async {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: _openingTime,
                        );
                        if (time != null) {
                          setState(() => _openingTime = time);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Closing Time'),
                      subtitle: Text(_closingTime.format(context)),
                      onTap: () async {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: _closingTime,
                        );
                        if (time != null && _isValidClosingTime(time)) {
                          setState(() => _closingTime = time);
                        } else if (time != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Closing time must be after opening time',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Arbitre disponible'),
                subtitle: const Text('Proposez un arbitre pour les matchs'),
                value: _hasReferee,
                onChanged: (value) {
                  setState(() {
                    _hasReferee = value;
                  });
                },
              ),
              if (_hasReferee) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _refereePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix de l\'arbitre (TND)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_hasReferee && (value == null || value.isEmpty)) {
                      return 'Veuillez entrer le prix de l\'arbitre';
                    }
                    if (_hasReferee && double.tryParse(value!) == null) {
                      return 'Veuillez entrer un prix valide';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              _buildWeeklyHoursSection(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Ajouter le terrain'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidClosingTime(TimeOfDay closingTime) {
    final now = DateTime.now();
    final opening = DateTime(
      now.year,
      now.month,
      now.day,
      _openingTime.hour,
      _openingTime.minute,
    );
    final closing = DateTime(
      now.year,
      now.month,
      now.day,
      closingTime.hour,
      closingTime.minute,
    );
    return closing.isAfter(opening);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner l\'emplacement du terrain'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, List<TimeOfDay>> weeklyHours = {};
      _customDayHours.forEach((day, custom) {
        if (_closedDays.contains(day)) return;
        if (custom != null) {
          weeklyHours[day] = [custom['opening']!, custom['closing']!];
        } else {
          weeklyHours[day] = [_openingTime, _closingTime];
        }
      });

      final field = FieldModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: context.read<AuthService>().currentUser!.uid,
        name: _nameController.text,
        description: _descriptionController.text,
        pricePerHour: double.parse(_priceController.text),
        address: _addressController.text,
        wilaya: _selectedWilaya,
        phone: _phoneController.text,
        images: _images,
        rating: 0,
        totalRatings: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        location: GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
        type: _selectedType,
        openingTime: _openingTime,
        closingTime: _closingTime,
        hasParking: _hasParking,
        hasLighting: _hasLighting,
        hasShowers: _hasShowers,
        hasChangingRooms: _hasChangingRooms,
        maxPlayers: _maxPlayers,
        hasBuffet: _hasBuffet,
        hasBalls: _hasBalls,
        hasJerseys: _hasJerseys,
        hasReferee: _hasReferee,
        refereePrice:
            _hasReferee ? double.parse(_refereePriceController.text) : 0.0,
        weeklyHours: weeklyHours,
        closedDays: _closedDays.toList(),
      );

      await context.read<FirestoreService>().addField(field);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

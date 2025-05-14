import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../models/field_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/map_viewer.dart';
import '../../widgets/payment_selection_dialog.dart';
import '../auth/login_screen.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/review_list.dart';
import '../../screens/user/add_review_screen.dart';
import '../../screens/user/edit_review_screen.dart';
import '../../models/review_model.dart';
import '../../providers/field_provider.dart';
import '../owner/edit_field_screen.dart';

class FieldDetailsScreen extends StatefulWidget {
  final FieldModel field;

  const FieldDetailsScreen({
    Key? key,
    required this.field,
  }) : super(key: key);

  @override
  State<FieldDetailsScreen> createState() => _FieldDetailsScreenState();
}

class _FieldDetailsScreenState extends State<FieldDetailsScreen> {
  late FieldModel _field;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  bool _isLoading = false;
  bool _withReferee = false;
  List<DateTime> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _field = widget.field;
    _loadAvailableTimeSlots();
  }

  double get _totalPrice {
    return _field.pricePerHour + (_withReferee ? _field.refereePrice : 0);
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);
    try {
      await context.read<BookingProvider>().loadAvailableTimeSlots(
            _field.id,
            _selectedDate!,
            _field.openingTime,
            _field.closingTime,
          );
      if (mounted) {
        setState(() {
          _availableTimeSlots =
              context.read<BookingProvider>().availableTimeSlots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );
        _selectedStartTime = null;
      });
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner une date d\'abord')),
      );
      return;
    }

    if (_isLoading) {
      return; // Don't show dialog while loading
    }

    if (_availableTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Aucun créneau disponible pour cette date')),
      );
      return;
    }

    // Show time slot selection dialog
    final TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner un créneau'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableTimeSlots.length,
              itemBuilder: (context, index) {
                final slot = _availableTimeSlots[index];
                final endTime = slot.add(const Duration(hours: 1));
                return ListTile(
                  title: Text(
                    '${TimeOfDay.fromDateTime(slot).format(context)} - ${TimeOfDay.fromDateTime(endTime).format(context)}',
                  ),
                  onTap: () {
                    Navigator.of(context).pop(TimeOfDay.fromDateTime(slot));
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _selectedStartTime = selectedTime;
      });
    }
  }

  Future<void> _bookField() async {
    if (_selectedDate == null || _selectedStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (result != true) return;
    }

    final startTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );
    final endTime = startTime.add(const Duration(hours: 1));

    // Check if the time slot is still available
    final isAvailable =
        await context.read<BookingProvider>().isTimeSlotAvailable(
              _field.id,
              startTime,
              endTime,
            );

    if (!isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This time slot is no longer available'),
        ),
      );
      _loadAvailableTimeSlots();
      return;
    }

    // Show payment selection dialog
    if (!mounted) return;
    final paymentMethod = await showDialog<String>(
      context: context,
      builder: (_) => PaymentSelectionDialog(
        amount: _totalPrice,
      ),
    );

    if (paymentMethod == null) return;

    // Create booking
    if (!mounted) return;
    try {
      setState(() => _isLoading = true);
      await context.read<BookingProvider>().createBooking(
            userId: context.read<AuthProvider>().user!.id,
            fieldId: _field.id,
            date: _selectedDate!,
            timeSlot:
                '${_selectedStartTime!.format(context)} - ${TimeOfDay.fromDateTime(endTime).format(context)}',
            amount: _totalPrice,
            paymentMethod: paymentMethod,
            withReferee: _withReferee,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildReviewsSection() {
    return StreamBuilder<List<ReviewModel>>(
      stream: _firestoreService.getFieldReviews(_field.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reviews = snapshot.data!;
        final currentUser = _authService.currentUser;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Avis (${reviews.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddReviewScreen(
                          field: _field,
                        ),
                      ),
                    );

                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Avis ajouté avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Ajouter un avis'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ReviewList(
              reviews: reviews,
              currentUserId: currentUser?.uid,
              onEdit: (review) async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditReviewScreen(
                      review: review,
                      field: _field,
                    ),
                  ),
                );

                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avis mis à jour avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              onDelete: (reviewId) async {
                try {
                  await _firestoreService.deleteReview(reviewId, _field.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Avis supprimé avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
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
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isOwner = user != null && user.id == _field.ownerId;
    return Scaffold(
      appBar: AppBar(
        title: Text(_field.name),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditFieldScreen(field: _field),
                  ),
                );
                if (result == true) {
                  // Refresh the field details
                  final updatedField =
                      await _firestoreService.getField(_field.id);
                  if (mounted) {
                    setState(() {
                      _field = updatedField;
                    });
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer le terrain'),
                    content: const Text(
                        'Êtes-vous sûr de vouloir supprimer ce terrain ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await Provider.of<FieldProvider>(context, listen: false)
                      .deleteField(_field.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terrain supprimé avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _field.images.isEmpty
                  ? Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )
                  : PageView.builder(
                      itemCount: _field.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _field.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _field.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_field.pricePerHour.toStringAsFixed(2)} TND/h',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_field.address}, ${_field.wilaya}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _field.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  MapViewer(
                    location: LatLng(
                      _field.location.latitude,
                      _field.location.longitude,
                    ),
                    title: _field.name,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Book this field',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  if (_selectedDate != null) ...[
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: _isLoading
                          ? const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Chargement des créneaux...'),
                              ],
                            )
                          : Text(
                              _selectedStartTime == null
                                  ? 'Sélectionner l\'heure'
                                  : _selectedStartTime!.format(context),
                            ),
                      onTap: _isLoading ? null : () => _selectTime(context),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_field.hasReferee) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ajouter un arbitre (+${_field.refereePrice} TND)',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Switch(
                          value: _withReferee,
                          onChanged: (value) {
                            setState(() {
                              _withReferee = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résumé des prix',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Prix du terrain'),
                            Text('${_field.pricePerHour} TND'),
                          ],
                        ),
                        if (_withReferee) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Prix de l\'arbitre'),
                              Text('${_field.refereePrice} TND'),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '$_totalPrice TND',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _selectedDate != null && _selectedStartTime != null
                              ? _bookField
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Book Now',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_field.hasParking)
                        _buildFeatureChip(
                          icon: Icons.local_parking,
                          label: 'Parking',
                        ),
                      if (_field.hasLighting)
                        _buildFeatureChip(
                          icon: Icons.lightbulb,
                          label: 'Éclairage',
                        ),
                      if (_field.hasShowers)
                        _buildFeatureChip(
                          icon: Icons.shower,
                          label: 'Douches',
                        ),
                      if (_field.hasChangingRooms)
                        _buildFeatureChip(
                          icon: Icons.dry_cleaning,
                          label: 'Vestiaires',
                        ),
                      // New features
                      _buildFeatureChip(
                        icon: Icons.people,
                        label: '${_field.maxPlayers} joueurs',
                      ),
                      if (_field.hasBuffet)
                        _buildFeatureChip(
                          icon: Icons.restaurant,
                          label: 'Buffet disponible',
                        ),
                      if (_field.hasBalls)
                        _buildFeatureChip(
                          icon: Icons.sports_soccer,
                          label: 'Ballons disponibles',
                        ),
                      if (_field.hasJerseys)
                        _buildFeatureChip(
                          icon: Icons.checkroom,
                          label: 'Maillots disponibles',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildReviewsSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon),
    );
  }
}

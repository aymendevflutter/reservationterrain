import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/booking_model.dart';
import '../../models/field_model.dart';

class FieldDetailsScreen extends StatefulWidget {
  final FieldModel field;

  const FieldDetailsScreen({Key? key, required this.field}) : super(key: key);

  @override
  _FieldDetailsScreenState createState() => _FieldDetailsScreenState();
}

class _FieldDetailsScreenState extends State<FieldDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _wantsReferee = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Features Section
              Text(
                'Caractéristiques',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Features Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3,
                children: [
                  if (widget.field.hasParking)
                    _buildFeatureChip(
                      icon: Icons.local_parking,
                      label: 'Parking',
                    ),
                  if (widget.field.hasLighting)
                    _buildFeatureChip(
                      icon: Icons.lightbulb_outline,
                      label: 'Éclairage',
                    ),
                  if (widget.field.hasShowers)
                    _buildFeatureChip(
                      icon: Icons.shower_outlined,
                      label: 'Douches',
                    ),
                  if (widget.field.hasChangingRooms)
                    _buildFeatureChip(
                      icon: Icons.dry_cleaning_outlined,
                      label: 'Vestiaires',
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Referee Section
              if (widget.field.hasReferee) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arbitre',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Prix de l\'arbitre: ${widget.field.refereePrice} TND',
                              style: theme.textTheme.bodyLarge,
                            ),
                            Switch(
                              value: _wantsReferee,
                              onChanged: (value) {
                                setState(() {
                                  _wantsReferee = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Reservation Section
              Text(
                'Réservation',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // ... existing reservation widgets ...
              const SizedBox(height: 16),
              // Total Price Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prix total',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prix du terrain',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          '${widget.field.pricePerHour} TND',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    if (_wantsReferee) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prix de l\'arbitre',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            '${widget.field.refereePrice} TND',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.field.pricePerHour + (_wantsReferee ? widget.field.refereePrice : 0)} TND',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _makeReservation,
        child: const Icon(Icons.book_online),
      ),
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthService>().currentUser;
      if (user == null) {
        throw Exception('Vous devez être connecté pour réserver');
      }

      final startTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );

      final endTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );

      final totalPrice = widget.field.pricePerHour +
          (_wantsReferee ? widget.field.refereePrice : 0);

      final booking = BookingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        fieldId: widget.field.id,
        userName: user.displayName ?? 'Utilisateur',
        userPhone: user.phoneNumber ?? '',
        fieldName: widget.field.name,
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPrice,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        paymentMethod: 'cash',
        withReferee: _wantsReferee,
      );

      await context.read<FirestoreService>().addBooking(booking);

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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/field_model.dart';
import '../../models/booking_model.dart';
import 'booking_details_screen.dart';
import 'weekly_schedule_screen.dart';
import 'edit_field_screen.dart';

class FieldDetailsScreen extends StatelessWidget {
  final FieldModel field;

  const FieldDetailsScreen({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(field.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditFieldScreen(field: field),
                ),
              );
              if (result == true) {
                // Optionally, you can refresh the field details here if needed
                // For now, just show a success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terrain modifié avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
                await context.read<FirestoreService>().deleteField(field.id);
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (field.images.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: field.images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      field.images[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        field.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${field.totalRatings} ratings)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    field.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, Icons.location_on, field.address),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, Icons.phone, field.phone),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.attach_money,
                    '${field.pricePerHour.toStringAsFixed(2)} TND/hour',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Bookings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildBookingsList(context),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WeeklyScheduleScreen(field: field),
                        ),
                      );
                    },
                    icon: const Icon(Icons.schedule),
                    label: const Text('Gérer l\'horaire hebdomadaire'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildBookingsList(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return StreamBuilder<List<BookingModel>>(
      stream: firestoreService.getBookingsByField(field.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data!;

        if (bookings.isEmpty) {
          return const Center(child: Text('No bookings yet'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('Booking #${booking.id}'),
                subtitle: Text(
                  '${booking.startTime} - ${booking.endTime}\n${booking.status}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingDetailsScreen(booking: booking),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

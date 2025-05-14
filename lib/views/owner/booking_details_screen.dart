import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/booking_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailsScreen({super.key, required this.booking});

  Future<void> _sendSms(String phoneNumber, String message) async {
    try {
      print("Sending SMS to: $phoneNumber");
      print("Message: $message");

      // Clean the phone number
      phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        // Fallback
        final fallbackUri =
            Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
        await launchUrl(fallbackUri);
      }
    } catch (e) {
      print("Error sending SMS: $e");
    }
  }

  Future<void> _updateBookingStatus(BuildContext context, String status) async {
    try {
      final firestoreService = context.read<FirestoreService>();

      // Update booking status
      await firestoreService.updateBookingStatus(booking.id, status);

      // Prepare SMS message based on status
      String message;
      if (status == 'confirmed') {
        message =
            'Votre réservation pour ${booking.fieldName ?? 'le terrain'} a été confirmée.\n\n'
            'Détails:\n'
            'Date: ${booking.startTime.toString().split(' ')[0]}\n'
            'Heure: ${booking.startTime.toString().split(' ')[1].substring(0, 5)} - ${booking.endTime.toString().split(' ')[1].substring(0, 5)}\n'
            'Prix: ${booking.totalPrice} TND\n'
            '${booking.withReferee ? 'Avec arbitre\n' : ''}'
            'Merci de votre confiance!';
      } else {
        message =
            'Votre réservation pour ${booking.fieldName ?? 'le terrain'} a été annulée.\n\n'
            'Détails:\n'
            'Date: ${booking.startTime.toString().split(' ')[0]}\n'
            'Heure: ${booking.startTime.toString().split(' ')[1].substring(0, 5)} - ${booking.endTime.toString().split(' ')[1].substring(0, 5)}\n'
            'Prix: ${booking.totalPrice} TND\n'
            '${booking.withReferee ? 'Avec arbitre\n' : ''}'
            'Nous vous prions de nous excuser pour ce désagrément.';
      }

      // Send SMS
      await _sendSms(booking.userPhone, message);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'confirmed'
                  ? 'Réservation confirmée et SMS envoyé'
                  : 'Réservation annulée et SMS envoyé',
            ),
            backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Réservation #${booking.id.substring(0, 8)}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails de la réservation',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Terrain',
                      booking.fieldName ?? 'Non spécifié',
                      Icons.sports_soccer,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Client',
                      booking.userName,
                      Icons.person,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Téléphone',
                      booking.userPhone,
                      Icons.phone,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Date',
                      booking.startTime.toString().split(' ')[0],
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Heure',
                      '${booking.startTime.toString().split(' ')[1].substring(0, 5)} - ${booking.endTime.toString().split(' ')[1].substring(0, 5)}',
                      Icons.access_time,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Prix',
                      '${booking.totalPrice} TND',
                      Icons.payments,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Mode de paiement',
                      booking.paymentMethod,
                      Icons.payment,
                    ),
                    if (booking.withReferee) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        'Arbitre',
                        'Inclus',
                        Icons.sports_score,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Statut',
                      booking.status,
                      Icons.info,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (booking.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateBookingStatus(context, 'confirmed'),
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _updateBookingStatus(context, 'cancelled'),
                      icon: const Icon(Icons.close),
                      label: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

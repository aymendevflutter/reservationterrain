import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/booking_model.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _confirmBooking() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _firestoreService.confirmBooking(widget.booking.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation confirmée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la confirmation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut: ${widget.booking.status}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${widget.booking.startTime.toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Heure: ${widget.booking.startTime.toString().split(' ')[1].substring(0, 5)} - ${widget.booking.endTime.toString().split(' ')[1].substring(0, 5)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Prix total: ${widget.booking.totalPrice} TND',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (widget.booking.withReferee)
                      Text(
                        'Avec arbitre',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                  ],
                ),
              ),
            ),
            if (widget.booking.status == 'pending') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmer la réservation',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

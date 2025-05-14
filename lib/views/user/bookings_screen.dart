import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).user!.id;
      await Provider.of<BookingProvider>(
        context,
        listen: false,
      ).loadUserBookings(userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.userBookings;

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: bookings.isEmpty
                  ? const Center(child: Text('No bookings found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date and Time
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(booking.startTime),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${DateFormat('HH:mm').format(booking.startTime)} - ${DateFormat('HH:mm').format(booking.endTime)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Status
                                Row(
                                  children: [
                                    Icon(
                                      booking.status == 'confirmed'
                                          ? Icons.check_circle
                                          : booking.status == 'pending'
                                              ? Icons.pending
                                              : Icons.cancel,
                                      size: 16,
                                      color: booking.status == 'confirmed'
                                          ? Colors.green
                                          : booking.status == 'pending'
                                              ? Colors.orange
                                              : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      booking.status.toUpperCase(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                            color: booking.status == 'confirmed'
                                                ? Colors.green
                                                : booking.status == 'pending'
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Amount
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_money,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${booking.totalPrice} TND',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

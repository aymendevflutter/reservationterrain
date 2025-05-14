import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/config/app_config.dart';
import '../models/payment_model.dart';
import '../models/payment.dart';

class PaymentService {
  final String _flouciBaseUrl = 'https://api.flouci.com/v1';
  final String _edinarBaseUrl = 'https://api.edinar.com/v1';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createFlouciPayment({
    required String bookingId,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_flouciBaseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.flouciApiKey}',
        },
        body: jsonEncode({
          'amount': amount,
          'description': description,
          'reference': bookingId,
          'accept_card': true,
          'success_url': AppConfig.flouciSuccessUrl,
          'cancel_url': AppConfig.flouciCancelUrl,
          'webhook_url': AppConfig.flouciWebhookUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payment_url'];
      } else {
        throw Exception('Failed to create Flouci payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create Flouci payment: $e');
    }
  }

  Future<String> createEdinarPayment({
    required String bookingId,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_edinarBaseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.edinarApiKey}',
        },
        body: jsonEncode({
          'amount': amount,
          'description': description,
          'reference': bookingId,
          'success_url': AppConfig.edinarSuccessUrl,
          'cancel_url': AppConfig.edinarCancelUrl,
          'webhook_url': AppConfig.edinarWebhookUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payment_url'];
      } else {
        throw Exception('Failed to create E-Dinar payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create E-Dinar payment: $e');
    }
  }

  Future<bool> verifyFlouciPayment(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_flouciBaseUrl/payments/$paymentId'),
        headers: {'Authorization': 'Bearer ${AppConfig.flouciApiKey}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'completed';
      } else {
        throw Exception('Failed to verify Flouci payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to verify Flouci payment: $e');
    }
  }

  Future<bool> verifyEdinarPayment(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_edinarBaseUrl/payments/$paymentId'),
        headers: {'Authorization': 'Bearer ${AppConfig.edinarApiKey}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'completed';
      } else {
        throw Exception('Failed to verify E-Dinar payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to verify E-Dinar payment: $e');
    }
  }

  Future<void> handleWebhook(Map<String, dynamic> payload) async {
    try {
      final paymentId = payload['payment_id'];
      final status = payload['status'];
      final method = payload['method'];

      if (status == 'completed') {
        // Update payment status in Firestore
        // Send notification to user
        // Update booking status
      }
    } catch (e) {
      throw Exception('Failed to handle webhook: $e');
    }
  }

  Future<PaymentModel> initiateFlouciPayment({
    required String userId,
    required String fieldId,
    required String bookingId,
    required double amount,
  }) async {
    final paymentUrl = await createFlouciPayment(
      bookingId: bookingId,
      amount: amount,
      description: 'Field booking payment',
    );

    return PaymentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      bookingId: bookingId,
      amount: amount,
      status: 'pending',
      paymentMethod: 'flouci',
      createdAt: DateTime.now(),
    );
  }

  Future<PaymentModel> createEDinarPayment({
    required String userId,
    required String fieldId,
    required String bookingId,
    required double amount,
  }) async {
    final paymentUrl = await createEdinarPayment(
      bookingId: bookingId,
      amount: amount,
      description: 'Field booking payment',
    );

    return PaymentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      bookingId: bookingId,
      amount: amount,
      status: 'pending',
      paymentMethod: 'edinar',
      createdAt: DateTime.now(),
    );
  }

  Future<Payment> processKonnectPayment({
    required String userId,
    required double amount,
  }) async {
    // Here you would integrate with Konnect's API
    // This is a placeholder for the actual Konnect integration
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      method: PaymentMethod.konnect,
      date: DateTime.now(),
      konnectTransactionId: 'KONNECT_${DateTime.now().millisecondsSinceEpoch}',
      isPaid: true,
    );

    await _firestore
        .collection('payments')
        .doc(payment.id)
        .set(payment.toMap());

    return payment;
  }

  Future<Payment> processCashPayment({
    required String userId,
    required double amount,
  }) async {
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      method: PaymentMethod.cash,
      date: DateTime.now(),
      isPaid: false, // Cash payments are marked as unpaid until confirmed
    );

    await _firestore
        .collection('payments')
        .doc(payment.id)
        .set(payment.toMap());

    return payment;
  }

  Future<void> confirmCashPayment(String paymentId) async {
    await _firestore.collection('payments').doc(paymentId).update({
      'isPaid': true,
    });
  }

  Stream<List<Payment>> getUserPayments(String userId) {
    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Payment.fromMap(doc.data())).toList();
    });
  }
}

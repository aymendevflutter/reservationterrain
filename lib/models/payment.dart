enum PaymentMethod {
  konnect,
  cash,
}

class Payment {
  final String id;
  final double amount;
  final PaymentMethod method;
  final DateTime date;
  final String? konnectTransactionId; // For Konnect payments
  final bool isPaid;

  Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
    this.konnectTransactionId,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'method': method.toString(),
      'date': date.toIso8601String(),
      'konnectTransactionId': konnectTransactionId,
      'isPaid': isPaid,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      amount: map['amount'],
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['method'],
      ),
      date: DateTime.parse(map['date']),
      konnectTransactionId: map['konnectTransactionId'],
      isPaid: map['isPaid'] ?? false,
    );
  }
} 
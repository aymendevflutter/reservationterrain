import 'package:flutter/material.dart';
import '../models/payment.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;
  final double amount;

  const PaymentMethodSelector({
    Key? key,
    this.selectedMethod,
    required this.onMethodSelected,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Konnect Payment'),
            subtitle: Text('Pay ${amount.toStringAsFixed(2)} TND online'),
            trailing: Radio<PaymentMethod>(
              value: PaymentMethod.konnect,
              groupValue: selectedMethod,
              onChanged: (value) {
                if (value != null) {
                  onMethodSelected(value);
                }
              },
            ),
            onTap: () => onMethodSelected(PaymentMethod.konnect),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Cash Payment'),
            subtitle: const Text('Pay in person when you arrive'),
            trailing: Radio<PaymentMethod>(
              value: PaymentMethod.cash,
              groupValue: selectedMethod,
              onChanged: (value) {
                if (value != null) {
                  onMethodSelected(value);
                }
              },
            ),
            onTap: () => onMethodSelected(PaymentMethod.cash),
          ),
        ),
      ],
    );
  }
}

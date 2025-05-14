import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/field_model.dart';
import '../../providers/field_provider.dart';

class WeeklyScheduleScreen extends StatefulWidget {
  final FieldModel field;

  const WeeklyScheduleScreen({Key? key, required this.field}) : super(key: key);

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  late Map<String, List<TimeOfDay>> _weeklyHours;
  late List<String> _closedDays;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weeklyHours = Map.from(widget.field.weeklyHours);
    _closedDays = List.from(widget.field.closedDays);
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedField = widget.field.copyWith(
        weeklyHours: _weeklyHours,
        closedDays: _closedDays,
        updatedAt: DateTime.now(),
      );

      await context.read<FieldProvider>().updateField(updatedField);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horaire mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleDayClosed(String day) {
    setState(() {
      if (_closedDays.contains(day)) {
        _closedDays.remove(day);
      } else {
        _closedDays.add(day);
        _weeklyHours.remove(day); // Clear hours when day is closed
      }
    });
  }

  Future<void> _addTimeSlot(String day) async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startTime.hour + 1,
        minute: startTime.minute,
      ),
    );

    if (endTime == null) return;

    setState(() {
      if (!_weeklyHours.containsKey(day)) {
        _weeklyHours[day] = [];
      }
      _weeklyHours[day]!.add(startTime);
      _weeklyHours[day]!.add(endTime);
      _weeklyHours[day]!.sort((a, b) => a.hour.compareTo(b.hour));
    });
  }

  void _removeTimeSlot(String day, int index) {
    setState(() {
      _weeklyHours[day]!.removeAt(index);
      if (_weeklyHours[day]!.isEmpty) {
        _weeklyHours.remove(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horaire hebdomadaire'),
      ),
      body: Form(
        key: _formKey,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isClosed = _closedDays.contains(day);
            final dayHours = _weeklyHours[day] ?? [];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      _getDayName(day),
                      style: theme.textTheme.titleMedium,
                    ),
                    trailing: Switch(
                      value: !isClosed,
                      onChanged: (value) => _toggleDayClosed(day),
                    ),
                  ),
                  if (!isClosed) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (dayHours.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Utiliser les heures par défaut (${widget.field.openingTime.format(context)} - ${widget.field.closingTime.format(context)})',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          if (dayHours.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dayHours.length ~/ 2,
                              itemBuilder: (context, timeIndex) {
                                final startTime = dayHours[timeIndex * 2];
                                final endTime = dayHours[timeIndex * 2 + 1];
                                return ListTile(
                                  title: Text(
                                    '${startTime.format(context)} - ${endTime.format(context)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () =>
                                        _removeTimeSlot(day, timeIndex * 2),
                                  ),
                                );
                              },
                            ),
                          TextButton.icon(
                            onPressed: () => _addTimeSlot(day),
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter un créneau'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveSchedule,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Enregistrer l\'horaire'),
          ),
        ),
      ),
    );
  }

  String _getDayName(String day) {
    switch (day) {
      case 'Monday':
        return 'Lundi';
      case 'Tuesday':
        return 'Mardi';
      case 'Wednesday':
        return 'Mercredi';
      case 'Thursday':
        return 'Jeudi';
      case 'Friday':
        return 'Vendredi';
      case 'Saturday':
        return 'Samedi';
      case 'Sunday':
        return 'Dimanche';
      default:
        return day;
    }
  }
}

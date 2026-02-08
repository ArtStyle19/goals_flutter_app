import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/constants/app_constants.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/core/utils/validators.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';

/// Multi-step form page for creating a new goal.
class CreateGoalPage extends ConsumerStatefulWidget {
  const CreateGoalPage({super.key});

  @override
  ConsumerState<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends ConsumerState<CreateGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _currentStep = 0;
  DateTime? _deadline;
  int _sessionDuration = 60;
  final Map<String, List<({String start, String end})>> _availability = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Meta')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (_currentStep < 3)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: details.onStepContinue,
                    child: const Text('Siguiente'),
                  )
                else
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _isSubmitting ? null : _onSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Crear Meta'),
                  ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Anterior'),
                  ),
              ],
            ),
          );
        },
        steps: [
          // ─── Step 1: Title & Description ───────────
          Step(
            title: const Text('Información'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: Validators.title,
                    decoration: const InputDecoration(
                      labelText: 'Título de la meta',
                      hintText: 'Ej: Aprender React',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      hintText: 'Describe tu meta brevemente',
                    ),
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),

          // ─── Step 2: Deadline ──────────────────────
          Step(
            title: const Text('Fecha límite'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _deadline != null
                        ? AppDateUtils.formatFull(_deadline!)
                        : 'Selecciona una fecha',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDeadline,
                ),
                if (_deadline != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${AppDateUtils.daysUntil(_deadline!)} días desde hoy',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),

          // ─── Step 3: Session Duration ──────────────
          Step(
            title: const Text('Duración de sesión'),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.sessionDurations.map((duration) {
                final isSelected = _sessionDuration == duration;
                return ChoiceChip(
                  label: Text(AppDateUtils.formatDuration(duration)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _sessionDuration = duration);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                );
              }).toList(),
            ),
            isActive: _currentStep >= 2,
          ),

          // ─── Step 4: Availability ──────────────────
          Step(
            title: const Text('Disponibilidad'),
            content: _AvailabilityBuilder(
              availability: _availability,
              onChanged: (updated) => setState(() {
                _availability
                  ..clear()
                  ..addAll(updated);
              }),
            ),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _onStepContinue() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;
    if (_currentStep == 1 && _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha límite')),
      );
      return;
    }
    if (_currentStep < 3) setState(() => _currentStep++);
  }

  void _onStepCancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _onSubmit() async {
    if (_availability.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un bloque de disponibilidad'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Build availability rules as domain entities
    final rules = <AvailabilityRuleEntity>[];
    _availability.forEach((day, slots) {
      for (final slot in slots) {
        rules.add(
          AvailabilityRuleEntity(day: day, start: slot.start, end: slot.end),
        );
      }
    });

    try {
      await ref
          .read(goalsProvider.notifier)
          .createGoal(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            deadline: _deadline!,
            sessionDurationMinutes: _sessionDuration,
            availabilityRules: rules,
          );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Meta creada exitosamente!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

// ─── Availability Builder Widget ──────────────────────────

class _AvailabilityBuilder extends StatelessWidget {
  final Map<String, List<({String start, String end})>> availability;
  final ValueChanged<Map<String, List<({String start, String end})>>> onChanged;

  const _AvailabilityBuilder({
    required this.availability,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona los días y horarios disponibles:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        // Day selector chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.weekDays.map((day) {
            final isSelected = availability.containsKey(day);
            return FilterChip(
              label: Text(AppConstants.dayShortLabels[day]!),
              selected: isSelected,
              onSelected: (selected) {
                final updated =
                    Map<String, List<({String start, String end})>>.from(
                      availability,
                    );
                if (selected) {
                  updated[day] = [(start: '09:00', end: '12:00')];
                } else {
                  updated.remove(day);
                }
                onChanged(updated);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Time slots for selected days
        ...availability.entries.map((entry) {
          final day = entry.key;
          final slots = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.dayLabels[day]!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...slots.asMap().entries.map((slotEntry) {
                  final index = slotEntry.key;
                  final slot = slotEntry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: () async {
                              final time = await _pickTime(context, slot.start);
                              if (time != null) {
                                final updated =
                                    Map<
                                      String,
                                      List<({String start, String end})>
                                    >.from(availability);
                                final daySlots =
                                    List<({String start, String end})>.from(
                                      updated[day]!,
                                    );
                                daySlots[index] = (start: time, end: slot.end);
                                updated[day] = daySlots;
                                onChanged(updated);
                              }
                            },
                            child: Text(slot.start),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('—'),
                        ),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: () async {
                              final time = await _pickTime(context, slot.end);
                              if (time != null) {
                                final updated =
                                    Map<
                                      String,
                                      List<({String start, String end})>
                                    >.from(availability);
                                final daySlots =
                                    List<({String start, String end})>.from(
                                      updated[day]!,
                                    );
                                daySlots[index] = (
                                  start: slot.start,
                                  end: time,
                                );
                                updated[day] = daySlots;
                                onChanged(updated);
                              }
                            },
                            child: Text(slot.end),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.error,
                          ),
                          onPressed: () {
                            final updated =
                                Map<
                                  String,
                                  List<({String start, String end})>
                                >.from(availability);
                            final daySlots =
                                List<({String start, String end})>.from(
                                  updated[day]!,
                                );
                            daySlots.removeAt(index);
                            if (daySlots.isEmpty) {
                              updated.remove(day);
                            } else {
                              updated[day] = daySlots;
                            }
                            onChanged(updated);
                          },
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar bloque'),
                  onPressed: () {
                    final updated =
                        Map<String, List<({String start, String end})>>.from(
                          availability,
                        );
                    updated[day] = [
                      ...updated[day]!,
                      (start: '14:00', end: '17:00'),
                    ];
                    onChanged(updated);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked != null) {
      return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }
}

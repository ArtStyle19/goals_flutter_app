import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/constants/app_constants.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';

/// Provider for the goal creation modal state.
final goalCreationProvider =
    StateNotifierProvider.autoDispose<GoalCreationNotifier, GoalCreationState>(
      (ref) => GoalCreationNotifier(),
    );

/// State class for goal creation modal.
class GoalCreationState {
  final int currentStep;
  final String title;
  final String description;
  final DateTime? deadline;
  final int sessionDuration;
  final Map<String, List<({String start, String end})>> availability;
  final String? selectedDay; // Currently selected day for editing
  final Map<String, String?> errors;
  final bool isSubmitting;

  const GoalCreationState({
    this.currentStep = 0,
    this.title = '',
    this.description = '',
    this.deadline,
    this.sessionDuration = 60,
    this.availability = const {},
    this.selectedDay,
    this.errors = const {},
    this.isSubmitting = false,
  });

  GoalCreationState copyWith({
    int? currentStep,
    String? title,
    String? description,
    DateTime? deadline,
    int? sessionDuration,
    Map<String, List<({String start, String end})>>? availability,
    String? selectedDay,
    Map<String, String?>? errors,
    bool? isSubmitting,
  }) {
    return GoalCreationState(
      currentStep: currentStep ?? this.currentStep,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      availability: availability ?? this.availability,
      selectedDay: selectedDay ?? this.selectedDay,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  /// Check if there's at least one time slot across all days
  bool get hasTimeSlots {
    if (availability.isEmpty) return false;
    for (final slots in availability.values) {
      if (slots.isNotEmpty) return true;
    }
    return false;
  }

  /// Get total number of time slots across all days
  int get totalTimeSlots {
    int count = 0;
    for (final slots in availability.values) {
      count += slots.length;
    }
    return count;
  }

  bool get canProceedToNext {
    return switch (currentStep) {
      0 => title.trim().isNotEmpty && title.trim().length >= 3,
      1 => deadline != null,
      2 => true, // Duration always has a value
      3 => hasTimeSlots, // Must have at least one actual time slot
      4 => true, // Preview step always valid
      _ => false,
    };
  }

  String? get currentStepError {
    return switch (currentStep) {
      0 => errors['title'],
      1 => errors['deadline'],
      3 => errors['availability'],
      _ => null,
    };
  }

  int get totalSteps => 5;

  double get progress => (currentStep + 1) / totalSteps;

  /// Get ordered list of days that have availability
  List<String> get selectedDays {
    return AppConstants.weekDays
        .where((day) => availability.containsKey(day))
        .toList();
  }
}

/// Notifier for managing goal creation state.
class GoalCreationNotifier extends StateNotifier<GoalCreationState> {
  GoalCreationNotifier() : super(const GoalCreationState());

  void nextStep() {
    if (state.currentStep < state.totalSteps - 1) {
      // When moving from step 3 to 4, deselect any day
      final newStep = state.currentStep + 1;
      state = state.copyWith(
        currentStep: newStep,
        selectedDay: newStep == 4 ? null : state.selectedDay,
        errors: {}, // Clear errors when moving forward
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      // When going back to step 3, deselect any day
      final newStep = state.currentStep - 1;
      state = state.copyWith(
        currentStep: newStep,
        selectedDay: newStep == 3 ? null : state.selectedDay,
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(
        currentStep: step,
        selectedDay: step == 3 ? null : state.selectedDay,
      );
    }
  }

  void setTitle(String value) {
    final trimmed = value.trim();
    String? error;
    if (trimmed.isEmpty) {
      error = 'El título es requerido';
    } else if (trimmed.length < 3) {
      error = 'Mínimo 3 caracteres';
    }

    state = state.copyWith(
      title: value,
      errors: {...state.errors, 'title': error},
    );
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setDeadline(DateTime value) {
    state = state.copyWith(
      deadline: value,
      errors: {...state.errors, 'deadline': null},
    );
  }

  void setSessionDuration(int value) {
    state = state.copyWith(sessionDuration: value);
  }

  void setAvailability(Map<String, List<({String start, String end})>> value) {
    final hasSlots = value.values.any((slots) => slots.isNotEmpty);
    final error = !hasSlots
        ? 'Selecciona al menos un día y agrega un horario'
        : null;
    state = state.copyWith(
      availability: value,
      errors: {...state.errors, 'availability': error},
    );
  }

  void selectDay(String day) {
    state = state.copyWith(selectedDay: day);
  }

  void deselectDay() {
    state = state.copyWith(selectedDay: null);
  }

  void toggleDay(String day) {
    final updated = Map<String, List<({String start, String end})>>.from(
      state.availability,
    );

    if (updated.containsKey(day)) {
      // Day already exists - just toggle selection for editing
      if (state.selectedDay == day) {
        // Deselect if already selected
        state = state.copyWith(selectedDay: null);
      } else {
        // Select this day for editing
        state = state.copyWith(selectedDay: day);
      }
    } else {
      // Add day with EMPTY slots list and select it
      // User must add time slots manually
      updated[day] = [];
      state = state.copyWith(
        availability: updated,
        selectedDay: day,
        errors: {...state.errors, 'availability': null},
      );
    }
  }

  void removeDay(String day) {
    final updated = Map<String, List<({String start, String end})>>.from(
      state.availability,
    );
    updated.remove(day);

    // If this was the selected day, deselect it
    final newSelectedDay = state.selectedDay == day ? null : state.selectedDay;

    // Check if we still have any time slots
    final hasSlots = updated.values.any((slots) => slots.isNotEmpty);

    state = state.copyWith(
      availability: updated,
      selectedDay: newSelectedDay,
      errors: {
        ...state.errors,
        'availability': !hasSlots
            ? 'Selecciona al menos un día y agrega un horario'
            : null,
      },
    );
  }

  void updateDaySlots(String day, List<({String start, String end})> slots) {
    final updated = Map<String, List<({String start, String end})>>.from(
      state.availability,
    );
    if (slots.isEmpty) {
      updated.remove(day);
    } else {
      updated[day] = slots;
    }

    // Check if we have at least one time slot
    final hasSlots = updated.values.any((s) => s.isNotEmpty);

    state = state.copyWith(
      availability: updated,
      errors: {
        ...state.errors,
        'availability': !hasSlots
            ? 'Selecciona al menos un día y agrega un horario'
            : null,
      },
    );
  }

  void setSubmitting(bool value) {
    state = state.copyWith(isSubmitting: value);
  }

  /// Validates current step and returns true if valid.
  bool validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        if (state.title.trim().isEmpty) {
          state = state.copyWith(
            errors: {...state.errors, 'title': 'El título es requerido'},
          );
          return false;
        }
        if (state.title.trim().length < 3) {
          state = state.copyWith(
            errors: {...state.errors, 'title': 'Mínimo 3 caracteres'},
          );
          return false;
        }
        return true;
      case 1:
        if (state.deadline == null) {
          state = state.copyWith(
            errors: {...state.errors, 'deadline': 'Selecciona una fecha'},
          );
          return false;
        }
        return true;
      case 3:
        // Validate that at least one time slot exists
        if (!state.hasTimeSlots) {
          state = state.copyWith(
            errors: {
              ...state.errors,
              'availability':
                  'Debes agregar al menos un horario para continuar',
            },
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  /// Builds the goal data for submission.
  GoalCreationData buildGoalData() {
    final rules = <AvailabilityRuleEntity>[];
    state.availability.forEach((day, slots) {
      for (final slot in slots) {
        rules.add(
          AvailabilityRuleEntity(day: day, start: slot.start, end: slot.end),
        );
      }
    });

    return GoalCreationData(
      title: state.title.trim(),
      description: state.description.trim().isEmpty
          ? null
          : state.description.trim(),
      deadline: state.deadline!,
      sessionDurationMinutes: state.sessionDuration,
      availabilityRules: rules,
    );
  }

  void reset() {
    state = const GoalCreationState();
  }
}

/// Data class for goal creation submission.
class GoalCreationData {
  final String title;
  final String? description;
  final DateTime deadline;
  final int sessionDurationMinutes;
  final List<AvailabilityRuleEntity> availabilityRules;

  const GoalCreationData({
    required this.title,
    this.description,
    required this.deadline,
    required this.sessionDurationMinutes,
    required this.availabilityRules,
  });
}

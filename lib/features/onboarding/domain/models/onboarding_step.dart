import 'package:flutter/foundation.dart';

/// Onboarding step data
@immutable
class OnboardingStep {
  final int index;
  final String title;
  final String description;
  final String imagePath;

  const OnboardingStep({
    required this.index,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  /// Default onboarding steps
  static const List<OnboardingStep> defaultSteps = [
    OnboardingStep(
      index: 0,
      title: 'Create Invoices Fast',
      description:
          'Send professional invoices in under 60 seconds. Track payments and never miss a follow-up.',
      imagePath: 'assets/images/onboarding_invoice.png',
    ),
    OnboardingStep(
      index: 1,
      title: 'Track Every Expense',
      description:
          'Snap receipts, categorize expenses, and maximize your tax deductions automatically.',
      imagePath: 'assets/images/onboarding_expense.png',
    ),
    OnboardingStep(
      index: 2,
      title: 'Know Your Numbers',
      description:
          'See your profit at a glance. Dashboard shows income, expenses, and outstanding invoices.',
      imagePath: 'assets/images/onboarding_dashboard.png',
    ),
  ];
}

/// Onboarding state
@immutable
class OnboardingState {
  final int currentStep;
  final bool isComplete;
  final bool hasSeenOnboarding;

  const OnboardingState({
    this.currentStep = 0,
    this.isComplete = false,
    this.hasSeenOnboarding = false,
  });

  bool get isLastStep => currentStep >= OnboardingStep.defaultSteps.length - 1;
  bool get isFirstStep => currentStep == 0;

  OnboardingState copyWith({
    int? currentStep,
    bool? isComplete,
    bool? hasSeenOnboarding,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }
}

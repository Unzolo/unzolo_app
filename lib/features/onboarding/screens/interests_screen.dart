import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selected = {};

  final List<String> _interests = [
    'Adventure', 'Exploring', 'Hiking',
    'Beaches', 'Mountains', 'Road Trips',
    'Photography', 'Culture', 'Spirituality',
    'City Trips', 'Solo Travels', 'Luxury Travel',
    'Budget Travel', 'Wildlife', 'Cuisine',
    'Public Transport Adventures', 'Nomad Life',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressBar(step: 3, total: 3),
              const SizedBox(height: 32),

              Text('Travel\nInterests', style: AppTextStyles.displayMedium)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                'Pick your travel interests to find the best matches',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_interests.length, (index) {
                      final interest = _interests[index];
                      final isSelected = _selected.contains(interest);
                      return _SelectChip(
                        label: interest,
                        isSelected: isSelected,
                        index: index,
                        onTap: () {
                          setState(() {
                            isSelected
                                ? _selected.remove(interest)
                                : _selected.add(interest);
                          });
                        },
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              AppButton(
                label: 'Find My Buddies',
                onPressed: _selected.isNotEmpty
                    ? () => context.push('/onboarding/matching')
                    : null,
              ).animate(delay: 500.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      delay: Duration(milliseconds: index * 40),
      effects: const [
        FadeEffect(),
        ScaleEffect(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;
  final int total;
  const _ProgressBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < total - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: index < step ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

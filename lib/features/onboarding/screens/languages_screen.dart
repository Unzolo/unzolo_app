import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final Set<String> _selected = {};
  final List<String> _languages = [
    'Malayalam', 'Tamil', 'Hindi', 'Telugu',
    'Kannada', 'Sanskrit', 'Arabic', 'Punjabi',
    'Bengali', 'Marathi', 'Gujarati', 'English',
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
              // Progress bar
              _ProgressBar(step: 1, total: 3),
              const SizedBox(height: 32),

              Text('Languages you\nSpeak', style: AppTextStyles.displayMedium)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                'Select languages to find compatible travel buddies',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 32),

              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_languages.length, (index) {
                    final lang = _languages[index];
                    final isSelected = _selected.contains(lang);
                    return _SelectChip(
                      label: lang,
                      isSelected: isSelected,
                      index: index,
                      onTap: () {
                        setState(() {
                          isSelected
                              ? _selected.remove(lang)
                              : _selected.add(lang);
                        });
                      },
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              AppButton(
                label: 'Next Step',
                onPressed: _selected.isNotEmpty
                    ? () => context.push('/onboarding/travel-style')
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
    return GestureDetector(
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
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
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
        final active = index < step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < total - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

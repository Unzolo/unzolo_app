import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';


class TravelStyleScreen extends StatefulWidget {
  const TravelStyleScreen({super.key});

  @override
  State<TravelStyleScreen> createState() => _TravelStyleScreenState();
}

class _TravelStyleScreenState extends State<TravelStyleScreen> {
  String? _selected;

  final List<_StyleOption> _styles = [
    _StyleOption('Solo', Icons.person_outline, 'Travel at your own pace'),
    _StyleOption('Couple', Icons.favorite_border, 'Romantic getaways'),
    _StyleOption('Group', Icons.group_outlined, 'Adventure with friends'),
    _StyleOption('Family', Icons.family_restroom_outlined, 'Family friendly trips'),
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
              _ProgressBar(step: 2, total: 3),
              const SizedBox(height: 32),

              Text('Your Travel\nStyle', style: AppTextStyles.displayMedium)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                'How do you like to travel?',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 32),

              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _styles.length,
                  itemBuilder: (context, index) {
                    final style = _styles[index];
                    final isSelected = _selected == style.name;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = style.name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              style.icon,
                              size: 36,
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              style.name,
                              style: AppTextStyles.titleLarge.copyWith(
                                color: isSelected
                                    ? AppColors.textOnPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              style.subtitle,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isSelected
                                    ? AppColors.textOnPrimary.withAlpha(204)
                                    : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(
                            delay: Duration(milliseconds: index * 80))
                        .fadeIn()
                        .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1, 1));
                  },
                ),
              ),

              AppButton(
                label: 'Next Step',
                onPressed: _selected != null
                    ? () => context.push('/onboarding/interests')
                    : null,
              ).animate(delay: 400.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleOption {
  final String name;
  final IconData icon;
  final String subtitle;
  _StyleOption(this.name, this.icon, this.subtitle);
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

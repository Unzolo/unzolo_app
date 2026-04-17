import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';

class ItineraryTimeline extends StatefulWidget {
  final List<MockDayItinerary> days;

  const ItineraryTimeline({super.key, required this.days});

  @override
  State<ItineraryTimeline> createState() => _ItineraryTimelineState();
}

class _ItineraryTimelineState extends State<ItineraryTimeline> {
  final Set<int> _expanded = {0}; // first day open by default

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.days.length, (index) {
        final day = widget.days[index];
        final isExpanded = _expanded.contains(index);
        final isLast = index == widget.days.length - 1;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 250 + index * 80),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(20 * (1 - value), 0),
              child: child,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline column
                SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      // Day circle
                      _DayCircle(
                        day: day.day,
                        isExpanded: isExpanded,
                      ),
                      // Connector line
                      if (!isLast)
                        Expanded(
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 2,
                              color: isExpanded
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: _DayCard(
                      day: day,
                      isExpanded: isExpanded,
                      onToggle: () {
                        setState(() {
                          isExpanded
                              ? _expanded.remove(index)
                              : _expanded.add(index);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final int day;
  final bool isExpanded;

  const _DayCircle({required this.day, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.primary : AppColors.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(
          color: isExpanded ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '$day',
          style: AppTextStyles.titleMedium.copyWith(
            color: isExpanded
                ? AppColors.textOnPrimary
                : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final MockDayItinerary day;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _DayCard({
    required this.day,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.primarySurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withAlpha(60)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Header row — always visible
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${day.day}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isExpanded
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          day.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isExpanded
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable activities
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: _ActivitiesList(activities: day.activities),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

class _ActivitiesList extends StatelessWidget {
  final List<String> activities;

  const _ActivitiesList({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          ...activities.map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      activity,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

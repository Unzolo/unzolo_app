import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class IncludedSection extends StatelessWidget {
  final List<String> items;

  const IncludedSection({super.key, required this.items});

  static const List<IconData> _icons = [
    Icons.hotel_outlined,
    Icons.restaurant_outlined,
    Icons.celebration_outlined,
    Icons.sports_cricket_outlined,
    Icons.hiking_outlined,
    Icons.directions_boat_outlined,
    Icons.camera_alt_outlined,
    Icons.music_note_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(items.length, (index) {
        final icon = _icons[index % _icons.length];
        return _IncludedChip(label: items[index], icon: icon, index: index);
      }),
    );
  }
}

class _IncludedChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;

  const _IncludedChip({
    required this.label,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

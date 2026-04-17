import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HighlightsSection extends StatelessWidget {
  final List<String> highlights;

  const HighlightsSection({super.key, required this.highlights});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(highlights.length, (index) {
        return Animate(
          delay: Duration(milliseconds: index * 80),
          effects: const [FadeEffect(), SlideEffect(begin: Offset(-0.2, 0), end: Offset.zero)],
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      highlights[index],
                      style: AppTextStyles.bodyMedium,
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

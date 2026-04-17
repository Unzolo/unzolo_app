import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../shared/widgets/user_avatar.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  bool _matched = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // After 3 seconds simulate match found
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _matched = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/shell/home');
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: _matched ? _MatchedView() : _SearchingView(
            pulseController: _pulseController,
            rotateController: _rotateController,
          ),
        ),
      ),
    );
  }
}

class _SearchingView extends StatelessWidget {
  final AnimationController pulseController;
  final AnimationController rotateController;

  const _SearchingView({
    required this.pulseController,
    required this.rotateController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing rings
              ...List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: pulseController,
                  builder: (ctx, child) {
                    final scale = 0.6 + (i * 0.15) +
                        (pulseController.value * 0.1 * (i + 1));
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary
                                .withAlpha(((0.4 - i * 0.1) * 255).round()),
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Rotating dashed circle
              AnimatedBuilder(
                animation: rotateController,
                builder: (_, child) => Transform.rotate(
                  angle: rotateController.value * 2 * pi,
                  child: child,
                ),
                child: CustomPaint(
                  size: const Size(160, 160),
                  painter: _DashedCirclePainter(color: AppColors.primary),
                ),
              ),

              // Center avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),

              // Floating match avatars
              ...List.generate(MockData.suggestedUsers.length, (i) {
                final angle = (i / MockData.suggestedUsers.length) * 2 * pi;
                final x = cos(angle) * 90.0;
                final y = sin(angle) * 90.0;
                return Positioned(
                  left: 110 + x - 18,
                  top: 110 + y - 18,
                  child: UserAvatar(
                    imageUrl: MockData.suggestedUsers[i].avatarUrl,
                    name: MockData.suggestedUsers[i].fullName,
                    size: 36,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                          begin: 0,
                          end: -4,
                          duration: Duration(
                              milliseconds: 1200 + i * 300),
                          curve: Curves.easeInOut),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 40),

        Text('Neural Match', style: AppTextStyles.headlineLarge)
            .animate()
            .fadeIn(),
        const SizedBox(height: 8),
        Text(
          'Finding your perfect\ntravel buddies...',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate(delay: 200.ms).fadeIn(),

        const SizedBox(height: 24),

        // Loading dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                    begin: 0,
                    end: -8,
                    delay: Duration(milliseconds: i * 150),
                    duration: 400.ms,
                    curve: Curves.easeOut)
                .then()
                .moveY(begin: -8, end: 0, duration: 400.ms);
          }),
        ),
      ],
    );
  }
}

class _MatchedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              size: 50, color: AppColors.primary),
        )
            .animate()
            .scale(begin: const Offset(0, 0), end: const Offset(1, 1),
                duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text('Buddies Found!', style: AppTextStyles.headlineLarge)
            .animate(delay: 300.ms)
            .fadeIn()
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 8),

        Text(
          'Taking you to your matches...',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(128)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashCount = 20;
    const dashAngle = 2 * pi / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * dashAngle;
        final sweepAngle = dashAngle * 0.7;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: size.height,
          ),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

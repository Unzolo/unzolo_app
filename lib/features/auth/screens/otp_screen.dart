import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  bool _isComplete = false;
  bool _isError = false;
  int _resendSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  final _defaultPinTheme = PinTheme(
    width: 56,
    height: 64,
    textStyle: AppTextStyles.headlineMedium.copyWith(
      color: AppColors.textPrimary,
    ),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final focusedPinTheme = _defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 2),
      color: AppColors.primarySurface,
    );

    final submittedPinTheme = _defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary),
      color: AppColors.primarySurface,
    );

    final errorPinTheme = _defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.error, width: 2),
      color: AppColors.error.withAlpha(20),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verify Code', style: AppTextStyles.displayMedium)
                .animate()
                .fadeIn()
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Please check your WhatsApp or SMS for the verification code',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 40),

            // Pin input
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: _isError
                  ? (Matrix4.translationValues(8, 0, 0))
                  : Matrix4.identity(),
              child: Pinput(
                controller: _controller,
                length: 6,
                defaultPinTheme: _defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                errorPinTheme: errorPinTheme,
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                onCompleted: (pin) {
                  setState(() {
                    _isComplete = true;
                    _isError = false;
                  });
                },
                onChanged: (val) {
                  setState(() {
                    _isComplete = val.length == 6;
                    _isError = false;
                  });
                },
              ),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 24),

            // Resend
            Center(
              child: _resendSeconds > 0
                  ? Text(
                      'Resend code in $_resendSeconds seconds',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        setState(() => _resendSeconds = 30);
                        _startTimer();
                      },
                      child: Text(
                        'Resend Code',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
            ).animate(delay: 300.ms).fadeIn(),

            const Spacer(),

            AppButton(
              label: 'Verify',
              onPressed: _isComplete
                  ? () => context.go('/onboarding/languages')
                  : null,
            ).animate(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

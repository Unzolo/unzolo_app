import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  bool _isValid = false;

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
              const SizedBox(height: 40),

              // Logo
              Container(
                width: 100,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'UNZOLO',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textOnPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0),

              const SizedBox(height: 40),

              Text(
                "What's your\nNumber?",
                style: AppTextStyles.displayMedium,
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              Text(
                'We\'ll send a 6-digit code to verify your number',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 32),

              // Phone field
              IntlPhoneField(
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  setState(() {
                    _isValid = phone.number.length >= 10;
                  });
                },
                style: AppTextStyles.bodyLarge,
                dropdownTextStyle: AppTextStyles.bodyMedium,
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'HAVE AN INVITE CODE?',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ).animate(delay: 500.ms).fadeIn(),

              const Spacer(),

              AppButton(
                label: 'Next',
                onPressed: _isValid ? () => context.push('/auth/otp') : null,
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3, end: 0),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'By continuing you agree to our Terms of Service\n& Privacy Policy',
                  style: AppTextStyles.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ).animate(delay: 700.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

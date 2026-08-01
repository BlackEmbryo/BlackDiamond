// Shared helpers used by onboard_dob_screen, onboard_upi_screen, onboard_referral_screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';

/// Shared progress bar widget for onboarding steps
class OnboardProgressBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  const OnboardProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Shared auth card container
class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.xlBR,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 30)],
      ),
      child: child,
    );
  }
}

/// Shared gold gradient button
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const GoldButton({super.key, required this.label, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: AppRadius.mdBR,
            boxShadow: [BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: const Color(0xFF1A0E00), letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}

/// Ghost outline button
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const GhostButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.mdBR,
        ),
        child: Text(label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
      ),
    );
  }
}

// ── Field Helpers (public so importable across files) ──────────────────────
Widget onboardFieldLabel(String text) => Text(text, style: GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.textSecondary));

Widget onboardStyledInput(TextEditingController ctrl, String hint,
    {TextInputType type = TextInputType.text}) {
  return TextField(
    controller: ctrl,
    keyboardType: type,
    style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
    ),
  );
}

Widget onboardPhoneInput(TextEditingController ctrl) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.bgSecondary,
      border: Border.all(color: AppColors.border),
      borderRadius: AppRadius.mdBR,
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: AppColors.border))),
        child: Text('🇮🇳 +91',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
      ),
      Expanded(
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter 10-digit number',
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    ]),
  );
}

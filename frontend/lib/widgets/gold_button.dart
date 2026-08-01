import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';

/// Shared gold-gradient CTA button used across auth and onboarding screens.
/// Replaces the duplicated `_GoldButton` (login_screen) and `_GoldBtn` (otp_screen).
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const GoldButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

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
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A0E00),
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

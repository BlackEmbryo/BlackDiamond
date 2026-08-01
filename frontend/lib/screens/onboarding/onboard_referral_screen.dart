import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../providers/app_state.dart';
import '../../widgets/toast_widget.dart';
import 'shared_widgets.dart';
import 'onboard_terms_screen.dart';

class OnboardReferralScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String upi;
  final String otpToken;
  const OnboardReferralScreen({super.key, required this.name, required this.mobile, required this.upi, required this.otpToken});
  @override
  State<OnboardReferralScreen> createState() => _OnboardReferralScreenState();
}

class _OnboardReferralScreenState extends State<OnboardReferralScreen> {
  final _refCtrl = TextEditingController();
  bool _bonusApplied = false;

  @override
  void initState() {
    super.initState();
    _refCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _refCtrl.dispose(); super.dispose(); }

  void _apply() {
    final code = _refCtrl.text.trim();
    if (code.isEmpty) { _goToTerms(); return; }
    
    // Bonus will be applied server-side during registration.
    setState(() => _bonusApplied = true);
    ToastService.show(context, 'Referral code accepted!', type: ToastType.success);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _goToTerms();
    });
  }

  void _goToTerms() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OnboardTermsScreen(
        name: widget.name, 
        mobile: widget.mobile, 
        upi: widget.upi,
        referredBy: _refCtrl.text.trim(),
        otpToken: widget.otpToken,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1), radius: 1.4,
            colors: [Color(0x14D4A853), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnboardProgressBar(progress: 0.8),
                    Text('Step 4 of 5',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.goldDim)),
                    const SizedBox(height: 20),
                    Text('Referral Code', style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('Have a referral code? Enter it for bonus credits',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    onboardFieldLabel('REFERRAL CODE (OPTIONAL)'),
                    const SizedBox(height: 8),
                    onboardStyledInput(_refCtrl, 'Enter code e.g. BD2024X'),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _bonusApplied
                          ? Container(
                              key: const ValueKey('bonus'),
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.08),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                                borderRadius: AppRadius.mdBR,
                              ),
                              child: Row(children: [
                                const Text('🎁', style: TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Bonus Credits Applied!', style: GoogleFonts.inter(
                                      fontSize: 14, fontWeight: FontWeight.w600,
                                      color: AppColors.gold)),
                                  const SizedBox(height: 2),
                                  Text('₹100 credits added to your account',
                                      style: GoogleFonts.inter(
                                          fontSize: 12, color: AppColors.textSecondary)),
                                ]),
                              ]),
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                    GoldButton(
                      label: 'Apply & Continue', 
                      onTap: _refCtrl.text.trim().isNotEmpty ? _apply : () {},
                      enabled: _refCtrl.text.trim().isNotEmpty,
                    ),
                    GhostButton(label: 'Skip', onTap: _goToTerms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

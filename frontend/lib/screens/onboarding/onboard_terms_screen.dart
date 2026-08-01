import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../providers/app_state.dart';
import '../../widgets/toast_widget.dart';
import '../../screens/main_shell.dart';
import 'shared_widgets.dart';
import 'onboard_pin_screen.dart';

class OnboardTermsScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String upi;
  final String? referredBy;
  final String otpToken;
  const OnboardTermsScreen({
    super.key, 
    required this.name, 
    required this.mobile, 
    required this.upi,
    this.referredBy,
    required this.otpToken,
  });
  @override
  State<OnboardTermsScreen> createState() => _OnboardTermsScreenState();
}

class _OnboardTermsScreenState extends State<OnboardTermsScreen> {
  bool _agreed = false;

  void _confirm() {
    if (!_agreed) {
      ToastService.show(context, 'Please agree to the Terms & Conditions', type: ToastType.error);
      return;
    }
    
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OnboardPinScreen(
        name: widget.name,
        mobile: widget.mobile,
        upi: widget.upi,
        referredBy: widget.referredBy,
        otpToken: widget.otpToken,
      ),
    ));
  }

  static const _termsItems = [
    'All investments are backed by physical metals held by a SEBI-licensed custodian (MMTC-PAMP / Augmont).',
    'Profits reflect real market price movement of the underlying metals.',
    'Credits represent the monetary value of metals purchased on your behalf.',
    'Withdrawals are processed within 2–5 business days via RazorpayX Payouts.',
    'A 2% transaction fee applies on all withdrawals.',
    'You must be 18 years or older to use this platform.',
    'Black Diamond is not liable for market losses on investments.',
    'Referral bonuses are credited after the referred user\'s first investment.',
  ];

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
                    OnboardProgressBar(progress: 1.0),
                    Text('Step 5 of 5',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.goldDim)),
                    const SizedBox(height: 20),
                    Text('Terms & Conditions', style: GoogleFonts.playfairDisplay(
                        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    // Scrollable terms box
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppRadius.mdBR,
                      ),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Black Diamond Investment Platform',
                                  style: GoogleFonts.inter(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: AppColors.gold)),
                              const SizedBox(height: 8),
                              Text('By using this platform, you agree to the following:',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              ..._termsItems.map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ', style: GoogleFonts.inter(
                                        fontSize: 12, color: AppColors.goldDim)),
                                    Expanded(child: Text(t, style: GoogleFonts.inter(
                                        fontSize: 12, color: AppColors.textSecondary, height: 1.6))),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Checkbox row
                    GestureDetector(
                      onTap: () => setState(() => _agreed = !_agreed),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _agreed,
                              onChanged: (v) => setState(() => _agreed = v ?? false),
                              activeColor: AppColors.gold,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'I have read and agree to the Terms & Conditions and Privacy Policy',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GoldButton(label: 'Confirm & Enter', onTap: _confirm, enabled: _agreed),
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

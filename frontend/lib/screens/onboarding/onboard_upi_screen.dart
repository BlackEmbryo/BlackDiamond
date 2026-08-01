import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../../widgets/toast_widget.dart';

import 'shared_widgets.dart';
import 'onboard_referral_screen.dart';

class OnboardUpiScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String otpToken;
  const OnboardUpiScreen({super.key, required this.name, required this.mobile, required this.otpToken});
  @override
  State<OnboardUpiScreen> createState() => _OnboardUpiScreenState();
}

class _OnboardUpiScreenState extends State<OnboardUpiScreen> {
  final _upiCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    _upiCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _upiCtrl.dispose(); super.dispose(); }

  void _continue() {
    final upi = _upiCtrl.text.trim();
    if (!RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(upi)) {
      ToastService.show(context, 'Please enter a valid UPI ID (e.g. name@okaxis)', type: ToastType.error);
      return;
    }
    
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OnboardReferralScreen(
        name: widget.name, 
        mobile: widget.mobile, 
        upi: upi,
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
                    const OnboardProgressBar(progress: 0.6),
                    Text('Step 3 of 5',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.goldDim)),
                    const SizedBox(height: 20),
                    Text('UPI ID', style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('Used for withdrawing your profits',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    onboardFieldLabel('YOUR UPI ID'),
                    const SizedBox(height: 8),
                    onboardStyledInput(_upiCtrl, 'yourname@upi'),
                    const SizedBox(height: 8),
                    Text('Example: name@okaxis, name@ybl, name@paytm',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.goldDim)),
                    const SizedBox(height: 20),
                    GoldButton(
                      label: 'Continue', 
                      onTap: _upiCtrl.text.trim().isNotEmpty ? _continue : () {},
                      enabled: _upiCtrl.text.trim().isNotEmpty,
                    ),
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

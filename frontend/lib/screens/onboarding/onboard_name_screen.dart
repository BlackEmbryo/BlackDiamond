import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../../widgets/toast_widget.dart';
import '../otp_screen.dart';
import 'shared_widgets.dart';

class OnboardNameScreen extends StatefulWidget {
  const OnboardNameScreen({super.key});
  @override
  State<OnboardNameScreen> createState() => _OnboardNameScreenState();
}

class _OnboardNameScreenState extends State<OnboardNameScreen> {
  final _nameCtrl   = TextEditingController();
  final _mobileCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  void _sendOTP() {
    final name   = _nameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    if (name.isEmpty) {
      ToastService.show(context, 'Please enter your name', type: ToastType.error); return;
    }
    if (mobile.length != 10 || !RegExp(r'^\d{10}$').hasMatch(mobile)) {
      ToastService.show(context, 'Please enter a valid 10-digit mobile number',
          type: ToastType.error); return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OtpScreen(
        mobile: mobile,
        flowType: 'onboard',
        onboardName: name,
      ),
    ));
    ToastService.show(context, 'OTP sent! Use 123456 for demo', type: ToastType.gold);
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
                    OnboardProgressBar(progress: 0.2),
                    Text('Step 1 of 5',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.goldDim)),
                    const SizedBox(height: 20),
                    Text("What's your name?", style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text("Let's get you set up",
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    onboardFieldLabel('FULL NAME'),
                    const SizedBox(height: 8),
                    onboardStyledInput(_nameCtrl, 'Enter your full name'),
                    const SizedBox(height: 20),
                    onboardFieldLabel('MOBILE NUMBER'),
                    const SizedBox(height: 8),
                    onboardPhoneInput(_mobileCtrl),
                    const SizedBox(height: 20),
                    GoldButton(label: 'Send OTP', onTap: _sendOTP),
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

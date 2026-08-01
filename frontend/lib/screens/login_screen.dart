import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../widgets/toast_widget.dart';
import '../widgets/gold_button.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';
import 'onboarding/onboard_name_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() { _mobileCtrl.dispose(); super.dispose(); }

  Future<void> _sendOTP() async {
    final mobile = _mobileCtrl.text.trim();
    final isValid = mobile.length == 10 && RegExp(r'^\d{10}$').hasMatch(mobile);
    if (!isValid) {
      ToastService.show(context, 'Please enter a valid 10-digit mobile number', type: ToastType.error);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final registered = await ApiService.checkMobile(mobile);
      if (!registered) {
        ToastService.show(context, 'Account not found. Please register.', type: ToastType.error);
        return;
      }
      
      await ApiService.sendOtp(mobile, 'login');
      
      if (!mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => OtpScreen(mobile: mobile, flowType: 'login'),
          transitionsBuilder: (_, a, __, child) =>
              SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(a), child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } catch (e) {
      ToastService.show(context, 'Failed to send OTP', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1.0),
            radius: 1.4,
            colors: [Color(0x14D4A853), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  border: Border.all(color: AppColors.border),
                  borderRadius: AppRadius.xlBR,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 30)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand logo
                    Row(children: [
                      Text('◆', style: GoogleFonts.inter(fontSize: 20, color: AppColors.gold,
                          shadows: [Shadow(color: AppColors.gold.withValues(alpha: 0.7), blurRadius: 6)])),
                      const SizedBox(width: 8),
                      Text('BLACK DIAMOND', style: GoogleFonts.playfairDisplay(
                          fontSize: 14, letterSpacing: 3, color: AppColors.gold)),
                    ]),
                    const SizedBox(height: 28),
                    Text('Welcome Back', style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('Enter your mobile number to continue',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    // Label
                    Text('MOBILE NUMBER', style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1,
                        color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    // Phone input with +91 prefix
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppRadius.mdBR,
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: AppColors.border)),
                          ),
                          child: Text('🇮🇳 +91', style: GoogleFonts.inter(
                              fontSize: 14, color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _mobileCtrl,
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
                            onSubmitted: (_) => _sendOTP(),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: GoldButton(
                        label: _isLoading ? 'Checking...' : 'Send OTP', 
                        onTap: _isLoading ? () {} : _sendOTP,
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const OnboardNameScreen())),
                        child: Text.rich(TextSpan(
                          text: 'New user? ',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                          children: [
                            TextSpan(text: 'Register here', style: GoogleFonts.inter(
                                color: AppColors.gold, decoration: TextDecoration.underline)),
                          ],
                        )),
                      ),
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


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/toast_widget.dart';
import '../../screens/main_shell.dart';
import 'shared_widgets.dart';

class OnboardPinScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String upi;
  final String? referredBy;
  final String otpToken;

  const OnboardPinScreen({
    super.key,
    required this.name,
    required this.mobile,
    required this.upi,
    this.referredBy,
    required this.otpToken,
  });

  @override
  State<OnboardPinScreen> createState() => _OnboardPinScreenState();
}

class _OnboardPinScreenState extends State<OnboardPinScreen> {
  final _pinCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final pin = _pinCtrl.text.trim();
    if (pin.length != 4) {
      ToastService.show(context, 'Please enter a 4-digit PIN', type: ToastType.error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.register(
        widget.name, 
        widget.mobile, 
        pin, 
        widget.otpToken,
        upiId: widget.upi.isNotEmpty ? widget.upi : null,
        referredBy: widget.referredBy?.isNotEmpty == true ? widget.referredBy : null,
      );

      if (!mounted) return;
      ToastService.show(context, 'Welcome to Black Diamond! ◆', type: ToastType.gold);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (e) {
      ToastService.show(context, e.toString(), type: ToastType.error);
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
                    const OnboardProgressBar(progress: 1.0),
                    Text('Final Step', style: GoogleFonts.inter(fontSize: 12, color: AppColors.goldDim)),
                    const SizedBox(height: 20),
                    Text('Set App PIN', style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('Create a 4-digit PIN to secure your account',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    onboardFieldLabel('4-DIGIT PIN'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pinCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.inter(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.bgSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: AppRadius.mdBR, borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.mdBR, borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: AppRadius.mdBR, borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GoldButton(
                      label: _isLoading ? 'Creating Account...' : 'Complete Setup', 
                      onTap: _isLoading ? () {} : _register,
                      enabled: !_isLoading,
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../providers/app_state.dart';
import '../widgets/toast_widget.dart';
import '../widgets/gold_button.dart';
import '../services/api_service.dart';
import '../screens/main_shell.dart';
import '../providers/auth_provider.dart';
import 'onboarding/onboard_dob_screen.dart';
import 'pin_auth_screen.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  final String flowType; // 'login' | 'onboard'
  final String? onboardName;
  final String? onboardUpi;

  const OtpScreen({
    super.key,
    required this.mobile,
    required this.flowType,
    this.onboardName,
    this.onboardUpi,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  int _timerSecs = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSecs = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _timerSecs--;
        if (_timerSecs <= 0) t.cancel();
      });
    });
  }

  Future<void> _resend() async {
    try {
      await ApiService.sendOtp(widget.mobile, widget.flowType);
      _startTimer();
      ToastService.show(context, 'OTP resent!', type: ToastType.gold);
    } catch (e) {
      ToastService.show(context, 'Failed to resend OTP', type: ToastType.error);
    }
  }

  Future<void> _verify() async {
    final otp = _ctrls.map((c) => c.text).join();
    if (otp.length != 6) {
      ToastService.show(context, 'Please enter the complete OTP', type: ToastType.error);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      if (widget.flowType == 'login') {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.otpLogin(widget.mobile, otp);
        _timer?.cancel();
        
        if (!mounted) return;
        ToastService.show(context, 'Welcome back! ◆', type: ToastType.gold);
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, a, __) => const MainShell(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
          (_) => false,
        );
      } else {
        final token = await ApiService.verifyOtp(widget.mobile, otp, widget.flowType) as String;
        _timer?.cancel();
        
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OnboardDobScreen(
            name: widget.onboardName ?? '',
            mobile: widget.mobile,
            otpToken: token, // Pass token to next screens until register is called
          ),
        ));
      }
    } catch (e) {
      ToastService.show(context, e.toString().replaceAll('Exception: ', ''), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UX-4: mask middle digits, not first 5
    final maskedMobile =
        '+91 XXXXX${widget.mobile.substring(5)}';

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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.gold, size: 18),
                      label: Text('Back',
                          style: GoogleFonts.inter(color: AppColors.gold, fontSize: 14)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                    const SizedBox(height: 12),
                    // Logo
                    Row(children: [
                      Text('◆', style: GoogleFonts.inter(fontSize: 20, color: AppColors.gold)),
                      const SizedBox(width: 8),
                      Text('BLACK DIAMOND', style: GoogleFonts.playfairDisplay(
                          fontSize: 14, letterSpacing: 3, color: AppColors.gold)),
                    ]),
                    const SizedBox(height: 28),
                    Text('Verify OTP', style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('OTP sent to $maskedMobile',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    // 6 OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (i) => _OtpBox(
                        ctrl: _ctrls[i],
                        node: _nodes[i],
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
                          if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                        },
                      )),
                    ),
                    const SizedBox(height: 20),
                    // Resend row
                    Center(
                      child: GestureDetector(
                        onTap: _timerSecs <= 0 ? _resend : null,
                        child: Text.rich(TextSpan(
                          text: "Didn't receive? ",
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                          children: [
                            TextSpan(
                              text: _timerSecs > 0
                                  ? 'Resend in ${_timerSecs}s'
                                  : 'Resend',
                              style: GoogleFonts.inter(
                                color: _timerSecs > 0
                                    ? AppColors.textMuted
                                    : AppColors.gold,
                                decoration: _timerSecs <= 0
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ],
                        )),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: GoldButton(
                        label: _isLoading ? 'Verifying...' : 'Verify & Continue', 
                        onTap: _isLoading ? () {} : _verify,
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text('Use 123456 for demo',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
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

class _OtpBox extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode node;
  final ValueChanged<String> onChanged;

  const _OtpBox({required this.ctrl, required this.node, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 54,
      child: TextField(
        controller: ctrl,
        focusNode: node,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gold),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.bgSecondary,
          border: OutlineInputBorder(
              borderRadius: AppRadius.mdBR,
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBR,
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBR,
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
        ),
        onChanged: (v) {
          final clean = v.replaceAll(RegExp(r'\D'), '');
          if (clean.length > 1) {
            ctrl.text = clean[clean.length - 1];
            ctrl.selection = TextSelection.fromPosition(
                TextPosition(offset: ctrl.text.length));
          }
          onChanged(ctrl.text);
        },
      ),
    );
  }
}


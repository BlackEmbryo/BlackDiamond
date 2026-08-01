import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app.dart';
import '../widgets/toast_widget.dart';
import '../providers/auth_provider.dart';
import 'main_shell.dart';
import 'login_screen.dart';

class PinAuthScreen extends StatefulWidget {
  final String mobile;
  
  const PinAuthScreen({super.key, required this.mobile});

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  String _pin = '';
  bool _isLoading = false;
  bool _isError = false;

  void _onKeyPress(String key) {
    if (_isLoading) return;
    
    setState(() {
      _isError = false; // clear error on new input
      
      if (key == '<') {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else if (_pin.length < 4) {
        _pin += key;
        if (_pin.length == 4) {
          _verifyPin();
        }
      }
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(widget.mobile, _pin);
      
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _pin = '';
        _isError = true;
      });
      ToastService.show(context, e.toString().replaceAll('Exception: ', ''), type: ToastType.error);
    }
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const LoginScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mask middle digits
    final maskedMobile = widget.mobile.length >= 10 
      ? '+91 XXXXX${widget.mobile.substring(5)}' 
      : widget.mobile;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.2,
            colors: [Color(0x1AD4A853), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header & Dots
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      // Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('◆', style: GoogleFonts.inter(fontSize: 24, color: AppColors.gold,
                              shadows: [Shadow(color: AppColors.gold.withOpacity(0.7), blurRadius: 8)])),
                          const SizedBox(width: 10),
                          Text('BLACK DIAMOND', style: GoogleFonts.playfairDisplay(
                              fontSize: 16, letterSpacing: 4, color: AppColors.gold)),
                        ],
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                      
                      const SizedBox(height: 30),
                      
                      Text('Enter App PIN', style: GoogleFonts.playfairDisplay(
                          fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text('Unlock session for $maskedMobile',
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                      
                      const SizedBox(height: 30),
                      
                      // PIN Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _pin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled ? AppColors.gold : Colors.transparent,
                              border: Border.all(
                                color: _isError 
                                  ? AppColors.red 
                                  : (isFilled ? AppColors.gold : AppColors.borderBright),
                                width: 1.5,
                              ),
                              boxShadow: isFilled ? [
                                BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 6)
                              ] : [],
                            ),
                          ).animate(target: _isError ? 1 : 0).shakeX(amount: 5, duration: 300.ms);
                        }),
                      ),
                      
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                        )
                      else
                        const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Custom Keypad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  border: const Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRow(['1', '2', '3']),
                    const SizedBox(height: 20),
                    _buildRow(['4', '5', '6']),
                    const SizedBox(height: 20),
                    _buildRow(['7', '8', '9']),
                    const SizedBox(height: 20),
                    _buildRow(['', '0', '<']),
                    const SizedBox(height: 30),
                    
                    // Switch Account
                    GestureDetector(
                      onTap: _isLoading ? null : _handleLogout,
                      child: Text('Not you? Log out & switch account', 
                        style: GoogleFonts.inter(
                          fontSize: 13, 
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        )
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox(width: 70, height: 70);
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _onKeyPress(key);
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgSecondary.withOpacity(0.5),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: key == '<'
                ? const Icon(Icons.backspace_outlined, color: AppColors.textSecondary, size: 24)
                : Text(key, style: GoogleFonts.inter(
                    fontSize: 26, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ),
        );
      }).toList(),
    );
  }
}

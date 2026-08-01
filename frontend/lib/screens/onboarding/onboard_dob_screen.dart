import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../../widgets/toast_widget.dart';
import 'shared_widgets.dart';
import 'onboard_upi_screen.dart';

class OnboardDobScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String otpToken;
  const OnboardDobScreen({super.key, required this.name, required this.mobile, required this.otpToken});
  @override
  State<OnboardDobScreen> createState() => _OnboardDobScreenState();
}

class _OnboardDobScreenState extends State<OnboardDobScreen> {
  DateTime? _dob;
  int? _age;
  bool _isValid = false;

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            onPrimary: Color(0xFF1A0E00),
            surface: AppColors.bgCard,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final age = _calcAge(picked);
    setState(() {
      _dob = picked;
      _age = age;
      _isValid = age >= 18;
    });
  }

  int _calcAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  void _continue() {
    if (_dob == null) {
      ToastService.show(context, 'Please select your date of birth', type: ToastType.error);
      return;
    }
    if (!_isValid) {
      ToastService.show(context, 'You must be 18 or older to invest', type: ToastType.error);
      return;
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OnboardUpiScreen(
            name: widget.name, 
            mobile: widget.mobile,
            otpToken: widget.otpToken,
          ),
        ));
      }
    });
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
                    OnboardProgressBar(progress: 0.4),
                    Text('Step 2 of 5', style: GoogleFonts.inter(fontSize: 12, color: AppColors.goldDim)),
                    const SizedBox(height: 20),
                    Text('Date of Birth', style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('You must be 18 or older to invest',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    onboardFieldLabel('DATE OF BIRTH'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          border: Border.all(color: _dob != null ? AppColors.gold : AppColors.border),
                          borderRadius: AppRadius.mdBR,
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                              _dob != null
                                  ? '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}'
                                  : 'Select date',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: _dob != null ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: AppColors.gold, size: 18),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Age badge
                    if (_age != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isValid
                              ? AppColors.green.withOpacity(0.15)
                              : AppColors.red.withOpacity(0.15),
                          border: Border.all(
                            color: _isValid
                                ? AppColors.green.withOpacity(0.3)
                                : AppColors.red.withOpacity(0.3),
                          ),
                          borderRadius: AppRadius.smBR,
                        ),
                        child: Text(
                          _isValid
                              ? '✓ Age verified: $_age years old'
                              : 'You are $_age years old — must be 18+ to invest',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isValid ? AppColors.green : AppColors.red,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    GoldButton(label: 'Continue', onTap: _continue, enabled: _isValid),
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

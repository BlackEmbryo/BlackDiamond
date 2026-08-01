import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../providers/app_state.dart';
import '../toast_widget.dart';
import 'modal_shared.dart';

void showWithdrawModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: Provider.of<AppState>(context, listen: false),
      child: const _WithdrawModal(),
    ),
  );
}

class _WithdrawModal extends StatefulWidget {
  const _WithdrawModal();
  @override
  State<_WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<_WithdrawModal> {
  final _amtCtrl  = TextEditingController();
  final _upiCtrl  = TextEditingController();
  double _fee = 0;
  double _net = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final upi = Provider.of<AppState>(context, listen: false).user?.upi ?? '';
    _upiCtrl.text = upi;
  }

  @override
  void dispose() {
    _amtCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  void _calcFee(String val) {
    final amt = double.tryParse(val) ?? 0;
    setState(() {
      _fee = amt * 0.02;
      _net = (amt - _fee).clamp(0, double.infinity);
    });
  }

  Future<void> _withdraw() async {
    final amt = double.tryParse(_amtCtrl.text) ?? 0;
    final upi = _upiCtrl.text.trim();
    if (amt <= 0) {
      ToastService.show(context, 'Please enter a valid withdrawal amount', type: ToastType.error);
      return;
    }
    if (upi.isEmpty) {
      ToastService.show(context, 'Please enter a UPI ID or bank account', type: ToastType.error);
      return;
    }
    final appState = Provider.of<AppState>(context, listen: false);
    if (amt > appState.realizedProfit) {
      ToastService.show(context, 'Amount exceeds available profit', type: ToastType.error);
      return;
    }

    setState(() => _isLoading = true);
    final amtFmt = AppState.formatCurrency(amt);
    
    try {
      final ok = await appState.processWithdraw(amt, upi);
      
      if (!mounted) return;
      Navigator.of(context).pop();
      
      if (ok) {
        ToastService.show(context, '✓ Withdrawal of $amtFmt initiated!', type: ToastType.success);
      } else {
        ToastService.show(context, 'Withdrawal failed', type: ToastType.error);
      }
    } catch (e) {
      ToastService.show(context, e.toString().replaceAll('Exception: ', ''), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: AppRadius.xl),
        border: Border(
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          top: BorderSide(color: AppColors.border),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 28, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Withdraw Profit',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const ModalCloseButton(),
            ],
          ),
          const SizedBox(height: 6),
          Text('Transfer to your bank / UPI',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border.all(color: AppColors.border),
              borderRadius: AppRadius.mdBR,
            ),
            child: Column(
              children: [
                _WiRow('Available Profit',    AppState.formatCurrency(appState.realizedProfit), isGold: true),
                const SizedBox(height: 6),
                _WiRow('Transaction Fee (2%)', AppState.formatCurrency(_fee)),
                const Divider(color: AppColors.border, height: 20),
                _WiRow('You Receive',          AppState.formatCurrency(_net), isGold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('ENTER AMOUNT TO WITHDRAW',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  letterSpacing: 1, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _amtCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '₹ Enter amount',
              hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            ),
            onChanged: _calcFee,
          ),
          const SizedBox(height: 16),
          Text('UPI ID / BANK ACCOUNT',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  letterSpacing: 1, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _upiCtrl,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'yourname@upi',
              hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isLoading ? null : _withdraw,
            child: Opacity(
              opacity: _isLoading ? 0.6 : 1.0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppGradients.withdrawBtn,
                  borderRadius: AppRadius.mdBR,
                ),
                alignment: Alignment.center,
                child: Text(_isLoading ? 'Processing...' : 'Withdraw via RazorpayX',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WiRow extends StatelessWidget {
  final String label, value;
  final bool isGold;
  const _WiRow(this.label, this.value, {this.isGold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: isGold ? AppColors.gold : AppColors.textPrimary)),
      ],
    );
  }
}

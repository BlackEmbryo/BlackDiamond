import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../providers/app_state.dart';
import '../toast_widget.dart';
import '../../providers/portfolio_provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'modal_shared.dart';

void showRechargeModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: Provider.of<AppState>(context, listen: false),
      child: const _RechargeModal(),
    ),
  );
}

class _RechargeModal extends StatefulWidget {
  const _RechargeModal();
  @override
  State<_RechargeModal> createState() => _RechargeModalState();
}

class _RechargeModalState extends State<_RechargeModal> {
  final _amtCtrl = TextEditingController();
  int? _selectedPreset;
  bool _isLoading = false;
  double _pendingAmt = 0;
  late Razorpay _razorpay;

  static const _presets = [500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amtCtrl.dispose();
    super.dispose();
  }

  // ── Razorpay Callbacks ──────────────────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final portfolio = Provider.of<PortfolioProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final ok = await portfolio.verifyRecharge(
        response.orderId ?? '',
        response.paymentId ?? '',
        response.signature ?? '',
        _pendingAmt,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      if (ok) {
        ToastService.show(
          context,
          '✓ ₹${_pendingAmt.toStringAsFixed(0)} credits added successfully!',
          type: ToastType.success,
        );
      } else {
        ToastService.show(context, 'Payment received but verification failed. Contact support.', type: ToastType.error);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      ToastService.show(context, 'Verification error: $msg', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    // response.message can be null when user simply dismisses the sheet
    final msg = (response.message != null && response.message!.isNotEmpty)
        ? response.message!
        : 'Payment cancelled';
    ToastService.show(context, msg, type: ToastType.error);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ToastService.show(
      context,
      'External wallet: ${response.walletName ?? 'selected'}',
      type: ToastType.gold,
    );
  }

  // ── Pay Button Logic ────────────────────────────────────────────────────

  Future<void> _pay() async {
    final amt = double.tryParse(_amtCtrl.text.trim()) ?? 0;
    if (amt < 100) {
      ToastService.show(context, 'Minimum recharge is ₹100', type: ToastType.error);
      return;
    }

    _pendingAmt = amt;
    setState(() => _isLoading = true);

    final portfolio = Provider.of<PortfolioProvider>(context, listen: false);
    final appState  = Provider.of<AppState>(context, listen: false);

    try {
      ToastService.show(context, 'Opening payment gateway...', type: ToastType.gold);
      final orderRes = await portfolio.createRechargeOrder(amt);

      final order = orderRes['order'] as Map<String, dynamic>;
      final keyId = orderRes['keyId']  as String? ?? '';

      // ── Demo mode: simulate payment without Razorpay SDK ─────────────
      if (orderRes['demo'] == true) {
        await Future.delayed(const Duration(milliseconds: 1500));
        final ok = await portfolio.verifyRecharge(
          order['id'] as String? ?? 'demo_order',
          'pay_${DateTime.now().millisecondsSinceEpoch}',
          'demo_sig',
          amt,
        );
        if (!mounted) return;
        Navigator.of(context).pop();
        ToastService.show(
          context,
          ok ? '✓ ₹${amt.toStringAsFixed(0)} demo credits added!' : 'Demo recharge failed',
          type: ok ? ToastType.success : ToastType.error,
        );
        return;
      }

      // ── Live mode: open Razorpay native checkout ──────────────────────
      // The native Android SDK does NOT support config.display.blocks — that
      // is the web-only JS checkout API.  Just open Razorpay with prefill so
      // the user's UPI ID and phone are pre-populated; Razorpay will show
      // GPay, PhonePe, UPI Collect, Card etc. from its own UI.
      final options = <String, dynamic>{
        'key':         keyId,
        'amount':      order['amount'],   // already in paise from backend
        'currency':    order['currency'] ?? 'INR',
        'name':        'Black Diamond ◆',
        'description': 'Recharge Credits — ₹${amt.toStringAsFixed(0)}',
        'order_id':    order['id'],
        'prefill': {
          'contact': appState.user?.mobile ?? '',
          'email':   'user@blackdiamond.app',
          // Pre-fill UPI ID if user has set one — saves them typing
          if ((appState.user?.upi ?? '').isNotEmpty)
            'vpa': appState.user!.upi,
        },
        'theme': {
          'color':      '#D4A853',
          'hide_topbar': false,
        },
        'notes': {
          'app': 'Black Diamond',
        },
      };

      _razorpay.open(options);
      // _isLoading stays true until success/error callback fires
    } catch (e) {
      setState(() => _isLoading = false);
      final msg = e.toString().replaceAll('Exception: ', '');
      ToastService.show(context, 'Error: $msg', type: ToastType.error);
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  void _setAmount(int amt, int idx) {
    setState(() {
      _selectedPreset = idx;
      _amtCtrl.text   = amt.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context, listen: false).user;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: AppRadius.xl),
        border: Border(
          left:  BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          top:   BorderSide(color: AppColors.border),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 28, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Credits',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const ModalCloseButton(),
            ],
          ),
          const SizedBox(height: 4),
          Text('Secure payment via Razorpay · GPay, UPI, Card',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),

          // ── Preset Amounts ────────────────────────────────────────────
          Row(
            children: List.generate(_presets.length, (i) {
              final isSelected = _selectedPreset == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < _presets.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => _setAmount(_presets[i], i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold.withValues(alpha: 0.12)
                            : AppColors.bgSecondary,
                        border: Border.all(
                            color: isSelected ? AppColors.gold : AppColors.border,
                            width: isSelected ? 1.5 : 1),
                        borderRadius: AppRadius.smBR,
                      ),
                      child: Text(
                        '₹${_presets[i] >= 1000 ? '${_presets[i] ~/ 1000}K' : _presets[i]}',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.gold : AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // ── Custom Amount ─────────────────────────────────────────────
          Text('CUSTOM AMOUNT',
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  letterSpacing: 1.2, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _amtCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixText: '₹  ',
              prefixStyle: GoogleFonts.inter(color: AppColors.goldDim, fontSize: 16),
              hintText: 'Enter amount (min ₹100)',
              hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
            ),
            onChanged: (_) => setState(() => _selectedPreset = null),
          ),

          // ── UPI pre-fill notice ───────────────────────────────────────
          if ((user?.upi ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.07),
                borderRadius: AppRadius.smBR,
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Icon(Icons.check_circle_outline, color: AppColors.goldDim, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'UPI pre-filled: ${user!.upi}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.goldDim),
                  ),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 20),

          // ── Pay Button ────────────────────────────────────────────────
          GestureDetector(
            onTap: _isLoading ? null : _pay,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _isLoading ? null : AppGradients.gold,
                color: _isLoading ? AppColors.bgSecondary : null,
                borderRadius: AppRadius.mdBR,
                border: _isLoading
                    ? Border.all(color: AppColors.border)
                    : null,
              ),
              alignment: Alignment.center,
              child: _isLoading
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Processing...',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                    ])
                  : Text('Pay via Razorpay',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A0E00), letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('GPay · PhonePe · UPI · Cards · Net Banking',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

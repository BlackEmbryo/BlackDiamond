import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../providers/app_state.dart';
import '../widgets/modals/withdraw_modal.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, appState, __) {
        final unrealized = appState.unrealizedGain;
        final totalVal   = appState.totalCurrentValue;

        return ListView(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transfer Cash',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 24, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Withdraw your profit to bank or UPI',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
            // ── Profit Hero ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppGradients.profitHero,
                border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                borderRadius: AppRadius.xlBR,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20, right: -10,
                    child: Text('₹',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 120,
                            color: AppColors.green.withValues(alpha: 0.04))),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: double.infinity),
                      Text('AVAILABLE PROFIT',
                          style: GoogleFonts.inter(
                              fontSize: 12, letterSpacing: 2,
                              color: AppColors.green.withValues(alpha: 0.7))),
                      const SizedBox(height: 8),
                      Text(
                        AppState.formatCurrency(appState.realizedProfit),
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 44, fontWeight: FontWeight.w900,
                            color: AppColors.green),
                      ),
                      const SizedBox(height: 4),
                      Text('Realized profits ready for withdrawal',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            // ── Withdraw Button ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              child: GestureDetector(
                onTap: () => showWithdrawModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: AppGradients.withdrawBtn,
                    borderRadius: AppRadius.lgBR,
                    boxShadow: [BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.25),
                        blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.currency_rupee, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text('Withdraw via RazorpayX',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            // ── Breakdown Table ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.border),
                borderRadius: AppRadius.lgBR,
              ),
              child: Column(
                children: [
                  _PbRow('Realized Profit',     AppState.formatCurrency(appState.realizedProfit),  valueColor: AppColors.green),
                  _PbRow('Unrealized Gain',     AppState.formatCurrency(unrealized),       valueColor: AppColors.gold),
                  _PbRow('Total Portfolio Value', AppState.formatCurrency(totalVal)),
                  _PbRow('Transaction Fee (2%)', 'on withdrawal'),
                  _PbRow('Processing Time',     '2–5 Business Days'),
                  _PbRow('Payout Via',          'RazorpayX Payouts', isLast: true),
                ],
              ),
            ),
            // ── Info Card ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.06),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                borderRadius: AppRadius.mdBR,
              ),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary, height: 1.7),
                  children: [
                    TextSpan(
                      text: 'How withdrawals work:\n',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, color: AppColors.gold),
                    ),
                    const TextSpan(
                      text:
                          'When you withdraw profit, your request is processed via RazorpayX Payouts and credited to your registered UPI ID or bank account within 2–5 business days. A 2% processing fee applies on the withdrawal amount.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PbRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isLast;
  const _PbRow(this.label, this.value, {this.valueColor, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0x12D4A853))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

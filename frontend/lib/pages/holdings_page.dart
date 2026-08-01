import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../widgets/modals/recharge_modal.dart';

class HoldingsPage extends StatelessWidget {
  const HoldingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, appState, __) {
        return ListView(
          children: [
            // ── Credit Balance Hero ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppGradients.holdingsHero,
                border: Border.all(color: AppColors.borderBright),
                borderRadius: AppRadius.xlBR,
              ),
              child: Stack(
                children: [
                  // Decorative ◆
                  Positioned(
                    top: -30, right: -30,
                    child: Text('◆',
                        style: TextStyle(
                            fontSize: 120,
                            color: AppColors.gold.withValues(alpha: 0.06))),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: double.infinity),
                      Text('CREDIT BALANCE',
                          style: GoogleFonts.inter(
                              fontSize: 12, letterSpacing: 2,
                              color: AppColors.goldDim)),
                      const SizedBox(height: 8),
                      Text(
                        AppState.formatCurrency(appState.credits),
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 44, fontWeight: FontWeight.w900,
                            color: AppColors.gold),
                      ),
                      const SizedBox(height: 4),
                      Text('In-app credits · Use to buy metals',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            // ── Action Buttons ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => showRechargeModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: AppGradients.gold,
                        borderRadius: AppRadius.mdBR,
                      ),
                      child: Column(
                        children: [
                          const Text('➕', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 6),
                          Text('Add Credits',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A0E00))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        Provider.of<AppState>(context, listen: false).setTab(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppRadius.mdBR,
                      ),
                      child: Column(
                        children: [
                          const Text('🛒', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 6),
                          Text('Buy Metals',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            // ── Transaction History ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text('Transaction History',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            if (appState.transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(children: [
                  const Text('📋', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('No transactions',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text('Your transaction history will appear here',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textMuted)),
                ]),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: appState.transactions
                      .map((tx) => _TransactionItem(tx: tx))
                      .toList(),
                ),
              ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final AppTransaction tx;
  const _TransactionItem({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == 'credit';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x14D4A853)),
        ),
      ),
      child: Row(children: [
        // Icon circle
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: isCredit
                ? AppColors.green.withValues(alpha: 0.1)
                : AppColors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(isCredit ? '⬇️' : '⬆️', style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        // Desc + date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tx.desc,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(tx.date,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        // Amount
        Text(
          '${isCredit ? '+' : '-'}${AppState.formatCurrency(tx.amount)}',
          style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.green : AppColors.red),
        ),
      ]),
    );
  }
}

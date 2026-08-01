import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../providers/app_state.dart';
import '../toast_widget.dart';
import '../../screens/login_screen.dart';
import 'modal_shared.dart';

void showProfileModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: Provider.of<AppState>(context, listen: false),
      child: const _ProfileModal(),
    ),
  );
}

class _ProfileModal extends StatelessWidget {
  const _ProfileModal();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;
    if (user == null) return const SizedBox.shrink();

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
          24, 28, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(alignment: Alignment.topRight, child: const ModalCloseButton()),
          const SizedBox(height: 8),
          Container(
            width: 70, height: 70,
            decoration: const BoxDecoration(
              gradient: AppGradients.gold, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(user.initials,
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A0E00))),
          ),
          const SizedBox(height: 12),
          Text(user.name,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('+91 ${user.mobile}',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          // Stats row
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdBR,
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(children: [
                Expanded(child: _PStat(AppState.formatCurrency(appState.credits), 'Credits', color: AppColors.gold)),
                Container(width: 1, color: AppColors.border),
                Expanded(child: _PStat(AppState.formatCurrency(appState.realizedProfit), 'Profit', color: AppColors.green)),
                Container(width: 1, color: AppColors.border),
                Expanded(child: _PStat(appState.stocks.length.toString(), 'Stocks')),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('UPI ID',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                Text(user.upi.isNotEmpty ? user.upi : '—',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Referral code box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.06),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
              borderRadius: AppRadius.mdBR,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Referral Code',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user.referralCode,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.w700,
                            letterSpacing: 2, color: AppColors.gold)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: user.referralCode));
                        ToastService.show(context,
                            'Referral code ${user.referralCode} copied!',
                            type: ToastType.gold);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppGradients.gold,
                          borderRadius: AppRadius.smBR,
                        ),
                        child: Text('Copy',
                            style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A0E00))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Sign Out
          Builder(builder: (ctx) {
            return GestureDetector(
              onTap: () {
                final state = Provider.of<AppState>(ctx, listen: false);
                final nav = Navigator.of(ctx);
                state.logout();
                nav.pop();
                ToastService.show(context, 'Signed out successfully', type: ToastType.gold);
                Future.delayed(const Duration(milliseconds: 600), () {
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: AppRadius.mdBR,
                ),
                alignment: Alignment.center,
                child: Text('Sign Out',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSecondary)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PStat extends StatelessWidget {
  final String value, label;
  final Color? color;
  const _PStat(this.value, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      color: AppColors.bgSecondary,
      child: Column(children: [
        Text(value,
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: color ?? AppColors.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
      ]),
    );
  }
}

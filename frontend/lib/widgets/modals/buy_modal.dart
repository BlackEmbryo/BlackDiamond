import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../providers/app_state.dart';
import '../../models/product.dart';
import '../toast_widget.dart';

void showBuyModal(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: Provider.of<AppState>(context, listen: false),
      child: _BuyModal(product: product),
    ),
  );
}

class _BuyModal extends StatefulWidget {
  final Product product;
  const _BuyModal({required this.product});
  @override
  State<_BuyModal> createState() => _BuyModalState();
}

class _BuyModalState extends State<_BuyModal> {
  final _qtyCtrl = TextEditingController();
  double _total = 0;
  bool _canBuy = false;
  bool _insufficient = false;
  bool _isLoading = false;

  @override
  void dispose() { _qtyCtrl.dispose(); super.dispose(); }

  void _calcTotal(String val) {
    final qty     = double.tryParse(val) ?? 0;
    final appState = Provider.of<AppState>(context, listen: false);
    final total   = qty * widget.product.pricePerGram;
    setState(() {
      _total       = total;
      _insufficient = qty > 0 && total > appState.credits;
      _canBuy      = qty > 0 && total <= appState.credits;
    });
  }

  Future<void> _confirm() async {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) {
      ToastService.show(context, 'Please enter a valid quantity', type: ToastType.error);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final ok = await appState.buyProduct(widget.product, qty);
      
      if (!mounted) return;
      Navigator.of(context).pop();
      
      if (ok) {
        ToastService.show(context,
            '✓ ${qty}g ${widget.product.name} purchased!', type: ToastType.success);
        appState.setTab(1); // go to My Stocks
      } else {
        ToastService.show(context,
            'Purchase failed', type: ToastType.error);
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
    final p        = widget.product;
    final up       = p.change >= 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: AppRadius.xl),
        border: Border(left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
            top:   BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 28, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close + Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Buy ${p.name}',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text('✕',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Secure purchase via your credit balance',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // Product preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border.all(color: AppColors.border),
              borderRadius: AppRadius.mdBR,
            ),
            child: Row(children: [
              ClipRRect(
                borderRadius: AppRadius.smBR,
                child: Image.asset(p.imagePath, width: 56, height: 56, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(p.quality,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('${up ? '▲ +' : '▼ '}${p.change.abs().toStringAsFixed(2)}% today',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: up ? AppColors.green : AppColors.red)),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 16),
          // Live price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Price',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
              Text('${AppState.formatPrice(p.pricePerGram)} / g',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 16),
          // Quantity input
          Text('QUANTITY (GRAMS)',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  letterSpacing: 1, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. 1.5',
              hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            ),
            onChanged: _calcTotal,
          ),
          const SizedBox(height: 12),
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border.all(color: AppColors.border),
              borderRadius: AppRadius.mdBR,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Credits Required',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted)),
                    Text(
                      _total > 0 ? AppState.formatCurrency(_total) : '₹0.00',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: _insufficient ? AppColors.red : AppColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Credit Balance',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted)),
                    Text(AppState.formatCurrency(appState.credits),
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Confirm button
          GestureDetector(
            onTap: (_canBuy && !_isLoading) ? _confirm : null,
            child: Opacity(
              opacity: _canBuy ? 1.0 : 0.4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: AppRadius.mdBR,
                ),
                alignment: Alignment.center,
                child: Text(_isLoading ? 'Processing...' : 'Confirm Purchase',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A0E00), letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

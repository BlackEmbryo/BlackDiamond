import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../providers/app_state.dart';
import '../models/stock.dart';
import '../models/product.dart';
import '../widgets/modals/buy_modal.dart';
import '../widgets/modals/sell_modal.dart';
class MyStocksPage extends StatelessWidget {
  const MyStocksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, appState, __) {
        final stocks   = appState.stocks;
        final products = appState.products;
        final totalVal = appState.totalCurrentValue;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Stocks',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 24, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Portfolio value: ',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                      children: [
                        TextSpan(
                          text: AppState.formatCurrency(totalVal),
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.gold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: stocks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📦', style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 16),
                          Text('No stocks yet',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 20, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('Go to Home and buy your first product',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textMuted)),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () =>
                                Provider.of<AppState>(context, listen: false).setTab(0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                gradient: AppGradients.gold,
                                borderRadius: AppRadius.mdBR,
                              ),
                              child: Text('Browse Products',
                                  style: GoogleFonts.inter(
                                      fontSize: 14, fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A0E00))),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemCount: stocks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) {
                        final stock   = stocks[i];
                        final product = products.firstWhere(
                          (p) => p.id == stock.productId,
                          orElse: () => products.first,
                        );
                        return _StockCard(stock: stock, product: product);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StockCard extends StatelessWidget {
  final Stock stock;
  final Product product;
  const _StockCard({required this.stock, required this.product});

  @override
  Widget build(BuildContext context) {
    final currentVal = product.pricePerGram * stock.quantity;
    final gainLoss   = currentVal - stock.credits;
    final gainPct    = ((gainLoss / stock.credits) * 100).toStringAsFixed(2);
    final isUp       = gainLoss >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.lgBR,
      ),
      child: Column(
        children: [
          Row(children: [
            // Thumbnail
            ClipRRect(
              borderRadius: AppRadius.mdBR,
              child: Image.asset(
                product.imagePath,
                width: 60, height: 60, fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('${stock.quantity}g · Bought ${stock.purchaseDate}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text('Avg: ${AppState.formatPrice(stock.purchasePrice)}/g',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            // Values
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(AppState.formatCurrency(currentVal),
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 17, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  '${isUp ? '+' : ''}${AppState.formatCurrencyShort(gainLoss)} (${isUp ? '+' : ''}$gainPct%)',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: isUp ? AppColors.green : AppColors.red),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => showSellModal(context, stock, product),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: AppRadius.mdBR,
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text('Sell',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.red)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => showBuyModal(context, product),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: AppRadius.mdBR,
                      border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text('Buy More',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.gold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

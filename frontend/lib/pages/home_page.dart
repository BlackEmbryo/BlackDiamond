import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../providers/app_state.dart';
import '../models/product.dart';
import '../widgets/modals/buy_modal.dart';

class HomePage extends StatefulWidget {
  final String searchQuery;
  const HomePage({super.key, this.searchQuery = ''});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, appState, __) {
        final user     = appState.user;
        final products = appState.filteredProducts(widget.searchQuery);

        return ListView(
          children: [
            // ── Hero Stats ─────────────────────────────────────────────────────
            _HeroSection(
              greeting: _greeting,
              name: user?.name.split(' ').first ?? 'Investor',
              credits: appState.credits,
              invested: appState.totalInvested,
              profit: appState.realizedProfit,
            ),
            // ── Market Ticker ──────────────────────────────────────────
            _MarketTicker(products: appState.products),
            // ── Category Tabs ──────────────────────────────────────────
            _CategoryTabs(
              active: appState.activeCategory,
              onSelect: appState.setCategory,
            ),
            // ── Section title ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Text('Featured Products',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            // ── Product Grid ───────────────────────────────────────────
            if (products.isEmpty)
              _EmptyState(icon: '🔍', title: 'No products found', sub: 'Try a different search term')
            else
              _ProductGrid(products: products),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// ── Hero Stats ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final String greeting, name;
  final double credits, invested, profit;
  const _HeroSection({
    required this.greeting, required this.name,
    required this.credits, required this.invested, required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
      decoration: BoxDecoration(
          gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.gold.withValues(alpha: 0.06), Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good $greeting,'.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('$name ◆',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _HeroStat(label: 'CREDITS',  value: AppState.formatCurrencyShort(credits), isProfit: false)),
            const SizedBox(width: 12),
            Expanded(child: _HeroStat(label: 'INVESTED', value: AppState.formatCurrencyShort(invested), isProfit: false)),
            const SizedBox(width: 12),
            Expanded(child: _HeroStat(label: 'PROFIT',   value: AppState.formatCurrencyShort(profit), isProfit: true)),
          ]),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label, value;
  final bool isProfit;
  const _HeroStat({required this.label, required this.value, required this.isProfit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.mdBR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold top bar
          Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(gradient: AppGradients.gold),
          ),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: isProfit ? AppColors.green : AppColors.gold)),
        ],
      ),
    );
  }
}

// ── Scrolling Ticker ────────────────────────────────────────────────────────
// PERF-2: use TickerProviderStateMixin + Ticker instead of Timer.periodic(30ms)
// so scrolling stays in sync with Flutter's vsync frame loop.
class _MarketTicker extends StatefulWidget {
  final List<Product> products;
  const _MarketTicker({required this.products});
  @override
  State<_MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<_MarketTicker>
    with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  static const double _pixelsPerSecond = 40.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    _ticker = createTicker((elapsed) {
      if (!_scroll.hasClients) return;
      final delta = elapsed - _lastElapsed;
      _lastElapsed = elapsed;
      final max = _scroll.position.maxScrollExtent;
      if (max == 0) return;
      final next = _scroll.offset + _pixelsPerSecond * delta.inMilliseconds / 1000;
      _scroll.jumpTo(next >= max ? 0 : next);
    });
    _ticker!.start();
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = [...widget.products, ...widget.products]; // duplicate for seamless loop
    return Container(
      height: 40,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 32),
        itemBuilder: (_, i) {
          final p = all[i];
          final up = p.change >= 0;
          return Center(
            child: Row(children: [
              Text(p.name,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(width: 8),
              Text(AppState.formatPrice(p.pricePerGram) + '/g',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Text(
                '${up ? '▲' : '▼'} ${p.change.abs().toStringAsFixed(2)}%',
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: up ? AppColors.green : AppColors.red),
              ),
            ]),
          );
        },
      ),
    );
  }
}

// ── Category Tabs ──────────────────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  final String active;
  final ValueChanged<String> onSelect;
  static const _cats = ['All', 'Gold', 'Gems', 'Silver'];
  const _CategoryTabs({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _cats[i];
          final isActive = cat == active;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: isActive ? AppGradients.gold : null,
                border: Border.all(color: isActive ? Colors.transparent : AppColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(cat,
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: isActive ? const Color(0xFF1A0E00) : AppColors.textMuted)),
            ),
          );
        },
      ),
    );
  }
}

// ── Product Grid ───────────────────────────────────────────────────────────
class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (_, i) => _ProductCard(product: products[i]),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});
  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final up = p.change >= 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        showBuyModal(context, p);
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // BUG-3 fix: card lifts up (-4) on hover, sits at 0 when idle
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(
              color: _hovered ? AppColors.borderBright : AppColors.border),
          borderRadius: AppRadius.lgBR,
          boxShadow: _hovered
              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 20)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: AppRadius.lg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(p.imagePath, fit: BoxFit.cover),
                    Positioned(
                      top: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.badgeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(p.badgeText,
                            style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                letterSpacing: 0.5, color: p.badgeTextColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(p.quality,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: AppState.formatPrice(p.pricePerGram),
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold),
                      ),
                      TextSpan(
                        text: '/g',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 2),
                  Text('${up ? '▲ +' : '▼ '}${p.change.abs().toStringAsFixed(2)}% today',
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: up ? AppColors.green : AppColors.red)),
                ],
              ),
            ),
            // Buy button
            GestureDetector(
              onTap: () => showBuyModal(context, p),
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: AppRadius.smBR,
                ),
                alignment: Alignment.center,
                child: Text('Buy Now',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A0E00))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String icon, title, sub;
  const _EmptyState({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(title,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(sub,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

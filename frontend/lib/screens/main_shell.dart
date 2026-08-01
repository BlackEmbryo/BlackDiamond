import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../providers/app_state.dart';
import '../pages/home_page.dart';
import '../pages/my_stocks_page.dart';
import '../pages/holdings_page.dart';
import '../pages/transfer_page.dart';
import '../widgets/modals/profile_modal.dart';
import '../widgets/toast_widget.dart';
import '../providers/portfolio_provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  bool _searchVisible = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final portfolio = Provider.of<PortfolioProvider>(context, listen: false);
      final appState = Provider.of<AppState>(context, listen: false);
      // Seed from saved session so ₹0.00 never flashes on screen
      final user = appState.user;
      if (user != null) {
        portfolio.seedFromUser(user.credits, user.realizedProfit);
      }
      portfolio.loadUserData();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) {
        _searchCtrl.clear();
        _searchQuery = '';
      }
    });
    if (_searchVisible) {
      // Switch to home if not there
      final state = Provider.of<AppState>(context, listen: false);
      if (state.currentTabIndex != 0) state.setTab(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    // ARCH-5: Auth guard — redirect to login if session is missing
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      });
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          // ── Top Navbar ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard.withValues(alpha: 0.85),
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(children: [
                  // Logo
                  _PulsingDiamond(),
                  const SizedBox(width: 8),
                  Text('BLACK DIAMOND',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 15, letterSpacing: 3, color: AppColors.textPrimary)),
                  const Spacer(),
                  // Search icon
                  _NavIconBtn(
                    icon: Icons.search,
                    onTap: _toggleSearch,
                  ),
                  const SizedBox(width: 6),
                  // Notification icon
                  _NavIconBtn(
                    icon: Icons.notifications_none,
                    badge: true,
                    onTap: () => ToastService.show(context, 'No new notifications'),
                  ),
                  const SizedBox(width: 6),
                  // Avatar button
                  GestureDetector(
                    onTap: () => showProfileModal(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        gradient: AppGradients.gold,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.initials,
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A0E00)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          // ── Search Bar ──────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: _searchVisible ? 56 : 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard.withValues(alpha: 0.85),
                border: const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: _searchVisible,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search Rose Gold, Rubies, Gold, Silver...',
                      hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                      border: OutlineInputBorder(
                          borderRadius: AppRadius.mdBR,
                          borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.mdBR,
                          borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.mdBR,
                          borderSide: const BorderSide(color: AppColors.gold)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _toggleSearch,
                  child: Text('✕',
                      style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
                ),
              ]),
            ),
          ),
          // ── Page Content ────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: appState.currentTabIndex,
              children: [
                HomePage(searchQuery: _searchQuery),
                const MyStocksPage(),
                const HoldingsPage(),
                const TransferPage(),
              ],
            ),
          ),
          // ── Bottom Nav ──────────────────────────────────────────────────
          _BottomNav(currentIndex: appState.currentTabIndex,
              onTap: (i) => Provider.of<AppState>(context, listen: false).setTab(i)),
        ],
      ),
    );
  }
}

// ── Pulsing Diamond Logo ───────────────────────────────────────────────────
class _PulsingDiamond extends StatefulWidget {
  @override
  State<_PulsingDiamond> createState() => _PulsingDiamondState();
}

class _PulsingDiamondState extends State<_PulsingDiamond>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Text(
        '◆',
        style: TextStyle(
          fontSize: 18,
          color: AppColors.gold,
          shadows: [
            Shadow(
              color: AppColors.gold.withValues(alpha: 0.4 + _ctrl.value * 0.5),
              blurRadius: 4 + _ctrl.value * 6,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav Icon Button ────────────────────────────────────────────────────────
class _NavIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  const _NavIconBtn({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            if (badge)
              Positioned(
                top: 7, right: 7,
                child: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.8), blurRadius: 6)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation ──────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.show_chart,    'label': 'My Stocks'},
    {'icon': Icons.business_center_outlined, 'label': 'Holdings'},
    {'icon': Icons.currency_rupee,'label': 'Transfer Cash'},
  ];

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.85),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_items.length, (i) {
            final isActive = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Gold indicator line at top
                    if (isActive)
                      Container(
                        height: 2,
                        decoration: const BoxDecoration(gradient: AppGradients.gold),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 4),
                          Icon(_items[i]['icon'] as IconData,
                              color: isActive ? AppColors.gold : AppColors.textMuted,
                              size: 22),
                          const SizedBox(height: 4),
                          Text(_items[i]['label'] as String,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: isActive ? AppColors.gold : AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

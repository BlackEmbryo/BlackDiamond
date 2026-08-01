import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/stock.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import 'auth_provider.dart';
import 'market_provider.dart';
import 'portfolio_provider.dart';

class AppState extends ChangeNotifier {
  final AuthProvider authProvider;
  final MarketProvider marketProvider;
  final PortfolioProvider portfolioProvider;

  int currentTabIndex = 0;

  AppState({
    required this.authProvider,
    required this.marketProvider,
    required this.portfolioProvider,
  }) {
    authProvider.addListener(notifyListeners);
    marketProvider.addListener(notifyListeners);
    portfolioProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    authProvider.removeListener(notifyListeners);
    marketProvider.removeListener(notifyListeners);
    portfolioProvider.removeListener(notifyListeners);
    super.dispose();
  }

  // ── Auth Delegates ────────────────────────────────────────────────────────
  AppUser? get user => authProvider.user;

  // For compatibility with old mock methods (now unused, but keeping signature if needed)
  void loginReturningUser(String mobile) {}
  void loginNewUser({required String name, required String mobile, required String upi}) {}
  void applyReferralBonus() {}
  Future<void> logout() => authProvider.logout();

  // ── Market Delegates ──────────────────────────────────────────────────────
  List<Product> get products => marketProvider.products;
  String get activeCategory => marketProvider.activeCategory;
  
  void setCategory(String cat) => marketProvider.setCategory(cat);
  List<Product> filteredProducts(String query) => marketProvider.filteredProducts(query);

  // ── Portfolio Delegates ───────────────────────────────────────────────────
  double get credits => portfolioProvider.credits;
  double get realizedProfit => portfolioProvider.realizedProfit;
  List<Stock> get stocks => portfolioProvider.stocks;
  List<AppTransaction> get transactions => portfolioProvider.transactions;

  Future<bool> buyProduct(Product product, double qty) async {
    return await portfolioProvider.buyProduct(product.id, qty);
  }

  Future<void> processRecharge(double amount) async {
    // Left for backward compat, but the UI should call the full Razorpay flow now
  }

  Future<bool> processWithdraw(double amount, String upiId) async {
    return await portfolioProvider.withdraw(amount, upiId);
  }

  double get totalInvested => portfolioProvider.totalInvested;
  double get totalCurrentValue => portfolioProvider.calculateTotalCurrentValue(marketProvider);
  double get unrealizedGain => portfolioProvider.calculateUnrealizedGain(marketProvider);
  double get totalProfit => realizedProfit + unrealizedGain;

  // ── UI State ──────────────────────────────────────────────────────────────
  void setTab(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  // ── Currency Formatting (Static helpers preserved) ────────────────────────
  static String formatCurrency(double n) {
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');
    return '₹${fmt.format(n)}';
  }

  static String formatCurrencyShort(double n) {
    final sign = n < 0 ? '-' : '';
    final abs = n.abs();
    if (abs >= 100000) return '${sign}₹${(abs / 100000).toStringAsFixed(2)}L';
    if (abs >= 1000)   return '${sign}₹${(abs / 1000).toStringAsFixed(1)}K';
    return '${sign}₹${abs.toStringAsFixed(2)}';
  }

  static String formatPrice(double n) {
    final fmt = NumberFormat('#,##,##0', 'en_IN');
    return '₹${fmt.format(n)}';
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import 'market_provider.dart';
import 'package:intl/intl.dart';

class PortfolioProvider extends ChangeNotifier {
  double credits = 0.0;
  double realizedProfit = 0.0;
  List<Stock> stocks = [];
  List<AppTransaction> transactions = [];
  bool isLoading = false;

  /// Pre-seed balances from the saved session so the UI has data
  /// immediately on startup before the full API refresh finishes.
  void seedFromUser(double userCredits, double userRealizedProfit) {
    if (credits == 0.0) credits = userCredits;
    if (realizedProfit == 0.0) realizedProfit = userRealizedProfit;
  }

  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();
    try {
      final profile = await ApiService.getProfile();
      credits = (profile['credits'] ?? 0.0).toDouble();
      realizedProfit = (profile['realizedProfit'] ?? 0.0).toDouble();

      final stocksData = await ApiService.getStocks();
      stocks = stocksData.map((s) => Stock.fromJson(s)).toList();

      final txData = await ApiService.getTransactions();
      transactions = txData.map((t) => AppTransaction.fromJson(t)).toList();
    } catch (e) {
      debugPrint('Failed to load portfolio: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> buyProduct(String productId, double quantity) async {
    try {
      final res = await ApiService.buyProduct(productId, quantity);
      if (res['success'] == true) {
        credits = (res['newCredits'] ?? credits).toDouble();
        stocks.add(Stock.fromJson(res['stock']));
        
        // Refresh transactions to get the new debit
        final txData = await ApiService.getTransactions();
        transactions = txData.map((t) => AppTransaction.fromJson(t)).toList();
        
        notifyListeners();
        return true;
      }
      throw Exception(res['message'] ?? 'Purchase failed');
    } catch (e) {
      debugPrint('Buy failed: $e');
      rethrow;
    }
  }

  Future<bool> sellStock(String stockId, double quantity) async {
    try {
      final res = await ApiService.sellProduct(stockId, quantity);
      if (res['success'] == true) {
        credits = (res['newCredits'] ?? credits).toDouble();
        realizedProfit = (res['newRealizedProfit'] ?? realizedProfit).toDouble();
        
        final updatedStock = res['stock'];
        final idx = stocks.indexWhere((s) => s.id == stockId);
        if (idx != -1) {
          if (updatedStock == null || (updatedStock['quantity'] ?? 0) <= 0) {
            stocks.removeAt(idx);
          } else {
            stocks[idx] = Stock.fromJson(updatedStock);
          }
        }
        
        final txData = await ApiService.getTransactions();
        transactions = txData.map((t) => AppTransaction.fromJson(t)).toList();
        
        notifyListeners();
        return true;
      }
      throw Exception(res['message'] ?? 'Sale failed');
    } catch (e) {
      debugPrint('Sell failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createRechargeOrder(double amount) async {
    return await ApiService.createOrder(amount);
  }

  Future<bool> verifyRecharge(String orderId, String paymentId, String signature, double amount) async {
    try {
      final res = await ApiService.verifyPayment(orderId, paymentId, signature, amount);
      // ApiService throws on failure so we get here only on success
      credits += ((res['credited'] as num?) ?? amount).toDouble();
      final txData = await ApiService.getTransactions();
      transactions = txData.map((t) => AppTransaction.fromJson(t)).toList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Recharge failed: $e');
      rethrow;
    }
  }

  Future<bool> withdraw(double amount, String upiId) async {
    try {
      // ApiService.payout throws on any failure, so getting here means success
      await ApiService.payout(amount, upiId);
      realizedProfit -= amount;
      final txData = await ApiService.getTransactions();
      transactions = txData.map((t) => AppTransaction.fromJson(t)).toList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Withdraw failed: $e');
      rethrow;
    }
  }

  void clear() {
    credits = 0;
    realizedProfit = 0;
    stocks = [];
    transactions = [];
    notifyListeners();
  }

  double get totalInvested => stocks.fold(0.0, (sum, s) => sum + s.credits);

  double calculateTotalCurrentValue(MarketProvider marketProvider) {
    if (marketProvider.products.isEmpty) return 0.0;
    return stocks.fold(0.0, (sum, s) {
      final p = marketProvider.products.firstWhere(
        (x) => x.id == s.productId, 
        orElse: () => marketProvider.products.first
      );
      return sum + p.pricePerGram * s.quantity;
    });
  }

  double calculateUnrealizedGain(MarketProvider marketProvider) {
    return max(0, calculateTotalCurrentValue(marketProvider) - totalInvested);
  }
}

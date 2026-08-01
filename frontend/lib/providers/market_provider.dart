import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class MarketProvider extends ChangeNotifier {
  List<Product> products = [];
  Timer? _marketTimer;

  String activeCategory = 'All';
  String _cachedCategory = '';
  String _cachedQuery = '';
  List<Product> _cachedFiltered = [];

  MarketProvider() {
    fetchProducts();
    _marketTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchProducts();
    });
  }

  @override
  void dispose() {
    _marketTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final data = await ApiService.getProducts();
      products = data.map<Product>((json) => Product.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch market products: $e');
    }
  }

  void setCategory(String cat) {
    activeCategory = cat;
    notifyListeners();
  }

  List<Product> filteredProducts(String query) {
    if (query == _cachedQuery && activeCategory == _cachedCategory && _cachedFiltered.isNotEmpty) {
      return _cachedFiltered;
    }
    _cachedQuery = query;
    _cachedCategory = activeCategory;
    _cachedFiltered = products.where((p) {
      if (activeCategory != 'All' && p.category != activeCategory) return false;
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query.toLowerCase()) ||
             p.quality.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return _cachedFiltered;
  }
}

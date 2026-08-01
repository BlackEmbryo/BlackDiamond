import 'package:flutter/material.dart';
import '../app.dart';

class Product {
  final String id;
  final String name;
  final String quality;
  double pricePerGram;
  double change;
  final String imagePath;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.quality,
    required this.pricePerGram,
    required this.change,
    required this.imagePath,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.category,
    required this.description,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final base = seedProducts.firstWhere((p) => p.id == id, orElse: () => seedProducts.first);
    return Product(
      id: id,
      name: base.name,
      quality: base.quality,
      pricePerGram: (json['pricePerGram'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      imagePath: base.imagePath,
      badgeText: base.badgeText,
      badgeColor: base.badgeColor,
      badgeTextColor: base.badgeTextColor,
      category: base.category,
      description: base.description,
    );
  }
}

/// Seed data matching JS PRODUCTS array exactly
final List<Product> seedProducts = [
  Product(
    id: 'rose-gold',
    name: 'Rose Gold',
    quality: '22K Rose Gold — Premium Grade',
    pricePerGram: 6850,
    change: 1.24,
    imagePath: 'assets/images/rose_gold.png',
    badgeText: 'Rose Gold',
    badgeColor: AppColors.roseGold.withValues(alpha: 0.85),
    badgeTextColor: const Color(0xFF1A0E00),
    category: 'Gold',
    description: 'Exquisite 22K rose gold, custodian-held by MMTC-PAMP. Known for its warm blush tone and lasting value.',
  ),
  Product(
    id: 'rubies',
    name: 'Rubies',
    quality: 'Premium Gemstone — Grade A',
    pricePerGram: 15200,
    change: 2.87,
    imagePath: 'assets/images/rubies.png',
    badgeText: 'Ruby',
    badgeColor: AppColors.ruby.withValues(alpha: 0.85),
    badgeTextColor: Colors.white,
    category: 'Gems',
    description: 'Deep red Grade A rubies, certified and vault-stored. Rarest of precious stones with unmatched appreciation.',
  ),
  Product(
    id: 'gold',
    name: 'Gold',
    quality: '24K Pure Gold — Investment Grade',
    pricePerGram: 7420,
    change: 0.95,
    imagePath: 'assets/images/gold.png',
    badgeText: '24K Gold',
    badgeColor: AppColors.gold.withValues(alpha: 0.85),
    badgeTextColor: const Color(0xFF1A0E00),
    category: 'Gold',
    description: 'Pure 24K investment gold at live market price. Held in secure Augmont vaults with full digital ownership.',
  ),
  Product(
    id: 'silver',
    name: 'Silver',
    quality: '925 Sterling Silver — Second Grade',
    pricePerGram: 92,
    change: -0.43,
    imagePath: 'assets/images/silver.png',
    badgeText: 'Silver',
    badgeColor: AppColors.silver.withValues(alpha: 0.85),
    badgeTextColor: const Color(0xFF1A0E00),
    category: 'Silver',
    description: '925 sterling silver at attractive entry price. Great diversification play with consistent long-term returns.',
  ),
];

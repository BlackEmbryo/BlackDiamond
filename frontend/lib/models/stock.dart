import 'package:intl/intl.dart';

class Stock {
  final String id;
  final String productId;
  final double quantity;
  final double purchasePrice;
  final String purchaseDate;
  final double credits; // amount paid = quantity * purchasePrice

  Stock({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.credits,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    final quantity      = ((json['quantity']      as num?) ?? 0).toDouble();
    // Backend sends 'buyPrice' from buyProduct, fallback to 'purchasePrice'
    final purchasePrice = ((json['buyPrice'] ?? json['purchasePrice'] as num?) ?? 0).toDouble();
    final credits       = ((json['credits']       as num?) ?? (quantity * purchasePrice)).toDouble();

    // Handle Firestore Timestamp or string for buyDate
    String purchaseDate = '';
    final ts = json['buyDate'] ?? json['purchaseDate'];
    if (ts is String) {
      purchaseDate = ts;
    } else if (ts is Map) {
      final seconds = ts['_seconds'] ?? ts['seconds'];
      if (seconds != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch((seconds as int) * 1000);
        purchaseDate = DateFormat('dd MMM yyyy').format(dt);
      }
    } else if (ts != null) {
      purchaseDate = ts.toString();
    }

    return Stock(
      id:            (json['id']        as String?) ?? '',
      productId:     (json['productId'] as String?) ?? '',
      quantity:      quantity,
      purchasePrice: purchasePrice,
      purchaseDate:  purchaseDate,
      credits:       credits,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'productId':     productId,
    'quantity':      quantity,
    'purchasePrice': purchasePrice,
    'purchaseDate':  purchaseDate,
    'credits':       credits,
  };
}

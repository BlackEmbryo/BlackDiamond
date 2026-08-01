import 'package:intl/intl.dart';

class AppTransaction {
  final String type; // 'credit' | 'debit'
  final String desc;
  final double amount;
  final String date;

  AppTransaction({
    required this.type,
    required this.desc,
    required this.amount,
    required this.date,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    // Backend sends 'timestamp' (Firestore Timestamp serialized as {seconds, nanoseconds} or as Date)
    // Safely parse into a readable date string
    String parsedDate = '';
    final ts = json['timestamp'];
    if (ts is String) {
      parsedDate = ts;
    } else if (ts is Map) {
      // Firestore Timestamp: {_seconds: int, _nanoseconds: int}
      final seconds = ts['_seconds'] ?? ts['seconds'];
      if (seconds != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch((seconds as int) * 1000);
        parsedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      }
    } else if (ts != null) {
      parsedDate = ts.toString();
    }
    if (parsedDate.isEmpty) parsedDate = json['date'] as String? ?? '';

    return AppTransaction(
      type:   (json['type']   as String?) ?? 'credit',
      desc:   (json['desc']   as String?) ?? '',
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      date:   parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'type':   type,
    'desc':   desc,
    'amount': amount,
    'date':   date,
  };
}

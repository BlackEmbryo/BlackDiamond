class AppUser {
  final String name;
  final String mobile;
  final String upi;
  final String referralCode;
  final String joinedDate;
  final double credits;
  final double realizedProfit;

  AppUser({
    required this.name,
    required this.mobile,
    required this.upi,
    required this.referralCode,
    required this.joinedDate,
    this.credits = 0.0,
    this.realizedProfit = 0.0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    name:           (json['name']         as String?) ?? '',
    mobile:         (json['mobile']       as String?) ?? '',
    upi:            (json['upiId']        as String?) ?? (json['upi'] as String?) ?? '',
    referralCode:   (json['referralCode'] as String?) ?? '',
    joinedDate:     (json['joinedDate']   as String?) ?? '',
    credits:        ((json['credits']       as num?) ?? 0).toDouble(),
    realizedProfit: ((json['realizedProfit'] as num?) ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'name':           name,
    'mobile':         mobile,
    'upiId':          upi,
    'referralCode':   referralCode,
    'joinedDate':     joinedDate,
    'credits':        credits,
    'realizedProfit': realizedProfit,
  };

  AppUser copyWith({
    String? name,
    String? mobile,
    String? upi,
    String? referralCode,
    String? joinedDate,
    double? credits,
    double? realizedProfit,
  }) => AppUser(
    name:           name ?? this.name,
    mobile:         mobile ?? this.mobile,
    upi:            upi ?? this.upi,
    referralCode:   referralCode ?? this.referralCode,
    joinedDate:     joinedDate ?? this.joinedDate,
    credits:        credits ?? this.credits,
    realizedProfit: realizedProfit ?? this.realizedProfit,
  );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'BD';
  }
}


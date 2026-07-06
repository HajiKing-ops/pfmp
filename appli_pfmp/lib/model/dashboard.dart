class DashboardStats {
  final int joursRenseignes;
  final int minutesTotales;

  const DashboardStats({
    required this.joursRenseignes,
    required this.minutesTotales,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      joursRenseignes: _readInt(json, [
        'joursRenseignes',
        'JoursRenseignes',
      ]),
      minutesTotales: _readInt(json, [
        'minutesTotales',
        'MinutesTotales',
      ]),
    );
  }
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
  }

  return 0;
}

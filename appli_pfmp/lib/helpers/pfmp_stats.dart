import 'package:appli_pfmp/model/pfmp.dart';

int plannedMinutesForPfmps(Iterable<Pfmp> pfmps) {
  return pfmps.fold<int>(
    0,
    (total, pfmp) => total + plannedMinutesForPfmp(pfmp),
  );
}

int plannedMinutesForPfmp(Pfmp pfmp) {
  final start = DateTime.tryParse(pfmp.dateDebut);
  final end = DateTime.tryParse(pfmp.dateFin);

  if (start == null || end == null || end.isBefore(start)) {
    return 0;
  }

  final minutesByWeekday = <int, int>{};
  for (final planningDay in pfmp.planning) {
    final weekday = _weekdayFromFrenchLabel(planningDay.jour);
    if (weekday == null) {
      continue;
    }
    minutesByWeekday[weekday] =
        (minutesByWeekday[weekday] ?? 0) + planningDay.totalHeures;
  }

  var total = 0;
  var current = DateTime(start.year, start.month, start.day);
  final last = DateTime(end.year, end.month, end.day);

  while (!current.isAfter(last)) {
    total += minutesByWeekday[current.weekday] ?? 0;
    current = current.add(const Duration(days: 1));
  }

  return total;
}

String formatMinutesAsHours(int minutes) {
  if (minutes <= 0) {
    return '0';
  }

  if (minutes % 60 == 0) {
    return (minutes ~/ 60).toString();
  }

  return (minutes / 60).toStringAsFixed(1).replaceAll('.', ',');
}

int? _weekdayFromFrenchLabel(String value) {
  switch (value.trim().toLowerCase()) {
    case 'lundi':
    case 'monday':
      return DateTime.monday;
    case 'mardi':
    case 'tuesday':
      return DateTime.tuesday;
    case 'mercredi':
    case 'wednesday':
      return DateTime.wednesday;
    case 'jeudi':
    case 'thursday':
      return DateTime.thursday;
    case 'vendredi':
    case 'friday':
      return DateTime.friday;
    case 'samedi':
    case 'saturday':
      return DateTime.saturday;
    case 'dimanche':
    case 'sunday':
      return DateTime.sunday;
  }

  return null;
}

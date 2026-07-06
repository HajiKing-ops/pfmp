import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/*
  DateFr est utilisé pour formater les dates en français sous la forme 'Jour 00 Mois AAAA'.
  Le package date_symbol_data_local.dart permet le formatage des partitions de date à la localité française.
*/

class DateFr extends StatelessWidget {
  final String date;
  final Color couleur;
  const DateFr({super.key, required this.date, required this.couleur});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    final dateStr = DateTime.parse(date.toString());
    final jourSemaine = DateFormat.EEEE('fr_FR').format(dateStr);
    final jourMois = DateFormat.d('fr_FR').format(dateStr);
    final mois = DateFormat.MMMM('fr_FR').format(dateStr);
    final annee = DateFormat.y('fr_FR').format(dateStr);
    String dateFormat;
    dateFormat =
        "${jourSemaine[0].toUpperCase()}${jourSemaine.substring(1)} $jourMois ${mois[0].toUpperCase()}${mois.substring(1)} $annee";
    return Text(
      dateFormat,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: couleur),
    );
  }
}

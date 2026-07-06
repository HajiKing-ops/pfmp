import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/*
  Ceci est la fonction utilisée dans les formulaires de création et de modification de démarche dans l'onglet "Recherche PFMP".
  Il s'agit d'une fonction asynchrone qui utilise la fonction showDatePicker.
  Cette dernier fournit un widget de sélection de date qui a été modifié afin d'obtenir l'interface qu'il possède actuellement.
  Une option de formatage de la date sélectionnée en français a aussi été implantée.
*/

Future dateSelectionnee(
  BuildContext context,
  DateTime dateContact,
  bool formatFr,
) async {
  DateTime dateFinale = dateContact;
  final DateTime? dateChoisie = await showDatePicker(
    context: context,
    locale: Locale("fr", "FR"),
    initialEntryMode: DatePickerEntryMode.input,

    initialDate: DateTime.now(),
    firstDate: DateTime(2025),
    lastDate: DateTime.now(),

    helpText: "Sélectionner une date",
    fieldLabelText: "Entrer une date",
    cancelText: "Annuler",
    confirmText: "Confirmer",

    builder: (context, child) {
      return Theme(data: ThemeData.dark(), child: child!);
    },
  );
  if (dateChoisie != null && dateChoisie != dateContact) {
    dateFinale = dateChoisie;
  }
  if (formatFr) {
    return dateFinale;
  } else {
    return DateFormat.yMMMMd("fr_FR").format(dateFinale);
  }
}

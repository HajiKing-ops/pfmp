import 'package:flutter/services.dart';

/*
  Il s'agit d'une extension de la classe TextInputFormatter, qui est utilisée dans le widget EntreeHoraire.
  Elle permet de formater l'horaire saisie sous la forme "HH:mm", plus de détails dans la classe.
*/

class HeureInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Uniquement des entiers (sinon remplacé par un whitespace, donc supprimé)
    var text = newValue.text.replaceAll(':', '');
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Pas plus de 4 caractères (sans compter ":")
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    // Si l'heure est en dessous de 06(h), saisie automatique à "06:00"
    if (text.length == 4 && int.parse(text.substring(0, 2)) < 06) {
      text = '0600';
    }

    // Si l'heure est au dessus de 21(h), saisie automatique à "21:00"
    if (text.length == 4 && int.parse(text.substring(0, 2)) > 21) {
      text = '2100';
    }

    String formatted = text;
    // A partir de la saisie du 3e caractère, ajout de ":" entre le 2e et le 3e
    if (text.length >= 3) {
      formatted = '${text.substring(0, 2)}:${text.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

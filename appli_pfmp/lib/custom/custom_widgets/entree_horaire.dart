import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_functions/formatage_horaire.dart';
import 'package:flutter/material.dart';

/*
  EntreeHoraire est un TexFormField personnalisé pour ne recevoir que des formats d'horaires compatibles, à savoir "HH:mm".
  Le texte rentré est modifié au fur de la saisie : ajout de ":" entre les heures et minutes, entiers seulement, et restrictions
  inscrites dans le fichier "appli_pfmp/custom/custom_widgets/formatage_horaire.dart".
*/

class EntreeHoraire extends StatefulWidget {
  final String? hint;
  final TextEditingController ctrlr;

  const EntreeHoraire({super.key, this.hint, required this.ctrlr});

  @override
  State<EntreeHoraire> createState() => _EntreeHoraireState();
}

class _EntreeHoraireState extends State<EntreeHoraire> {
  @override
  Widget build(BuildContext context) {
    final String? hint = widget.hint;
    final TextEditingController ctrlr = widget.ctrlr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            fillColor: couleurWidget,
            filled: true,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.blueGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [HeureInputFormatter()],
          controller: ctrlr,
        ),
      ],
    );
  }
}

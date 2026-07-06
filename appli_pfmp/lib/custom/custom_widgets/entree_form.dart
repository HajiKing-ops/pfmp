import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:flutter/material.dart';

/*
  EntreeForm correspond aux TextFormField classiques utilisés dans tous les formulaires de l'application.
  Les couleurs sont modifiées, un controleur lui est obligatoirement associé, ainsi qu'un placeholder optionnel.
  Quant au booléen obligatoire, il permet si 'true', d'afficher un message d'obligation de saisie lors de l'envoi du formulaire.
*/

class EntreeForm extends StatelessWidget {
  final String txt;
  final String? hint;
  final TextEditingController ctrlr;
  final bool obligatoire;

  const EntreeForm({
    super.key,
    required this.txt,
    this.hint,
    required this.ctrlr,
    required this.obligatoire,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(txt, style: const TextStyle(color: Colors.grey)),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              fillColor: couleurWidget,
              filled: true,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.blueGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            controller: ctrlr,
            validator: (value) {
              if (obligatoire && (value == null || value.isEmpty)) {
                return 'Ce champ est obligatoire';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

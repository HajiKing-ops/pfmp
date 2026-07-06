import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:flutter/material.dart';

/*
  Ce widget est créé pour les bouton de sélection de jours travaillés dans le formulaire de création de PFMP.
  Il lui est associé un booléen jourPresse dont la valeur traduit sa couleur ainsi que, plus tard, l'affichage des containers de saisie d'horaires.
*/

class BoutonPoussoir extends StatefulWidget {
  final String txt;
  final bool jourPresse;

  const BoutonPoussoir({super.key, required this.txt, required this.jourPresse});

  @override
  State<BoutonPoussoir> createState() => _BoutonPoussoirState();
}

class _BoutonPoussoirState extends State<BoutonPoussoir> {
  @override
  Widget build(BuildContext context) {
    var txt = widget.txt;
    var jourPresse = widget.jourPresse;

    return Flexible(
      // Bouton Lundi
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: BorderSide(color: Colors.black),
          backgroundColor: jourPresse
              ? Colors.amber
              : couleurFormulaire,
          textStyle: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          setState(() {
            jourPresse = !jourPresse;
          });
        },
        child: Text(txt),
      ),
    );
  }
}

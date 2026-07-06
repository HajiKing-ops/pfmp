import 'package:flutter/material.dart';

/*
  Il s'agit certainement du widget le plus utilisé dans l'application.
  Il représente un simple bouton dont le texte inscrit, sa couleur, celle du bouton et la fonction qui lui est associé est modifiable.
*/

class BoutonTexte extends StatelessWidget {
  final String txt;
  final Function? fct;
  final Color? couleur;
  final Color? couleurTxt;
  const BoutonTexte({
    super.key,
    required this.txt,
    this.fct,
    this.couleur,
    this.couleurTxt,
  });

  @override
  Widget build(BuildContext context) {
    final clr = couleur ?? Colors.amber;
    final clrTxt = couleurTxt ?? Colors.black;

    return TextButton(
      onPressed: fct == null ? null : () => fct!(),
      style: TextButton.styleFrom(
        backgroundColor: clr,
        foregroundColor: clrTxt,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        minimumSize: const Size(44, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        txt,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(color: clrTxt),
      ),
    );
  }
}

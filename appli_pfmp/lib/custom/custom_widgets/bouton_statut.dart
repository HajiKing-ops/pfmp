import 'package:flutter/material.dart';

/*
  Ce widget est utilisé dans le formulaire de modification de démarches.
  Il s'agit d'un bouton qui change de statut, de couleur et de texte au clic.
  Dans ce cas : "En attente", "Refuse" ou "Accepte" et orange, rouge ou vert.
  Ces données sont ensuite envoyées pour changer le statut de la démarche modifiée.
*/

class BoutonStatut extends StatefulWidget {
  final ValueChanged<String> onChangementStatut;
  final String statutInitial;

  const BoutonStatut({
    super.key,
    required this.onChangementStatut,
    required this.statutInitial,
  });

  @override
  State<BoutonStatut> createState() => _BoutonStatutState();
}

class _BoutonStatutState extends State<BoutonStatut> {
  final List<String> statuts = ["En attente", "Refuse", "Accepte"];
  final List<Color> couleurs = [Colors.amber, Colors.red, Colors.green];
  int statutIndex = 0;

  @override
  void initState() {
    super.initState();
    final index = statuts.indexOf(widget.statutInitial);
    setState(() {
      statutIndex = (index != -1) ? index : 0;
    });
  }

  void onClick() {
    setState(() {
      statutIndex = (statutIndex + 1) % statuts.length;
    });
    widget.onChangementStatut(statuts[statutIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final int safeIndex = statutIndex.clamp(0, statuts.length - 1);
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(couleurs[safeIndex]),
        textStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(color: Colors.black),
        ),
      ),
      onPressed: onClick,
      child: Text(statuts[safeIndex]),
    );
  }
}

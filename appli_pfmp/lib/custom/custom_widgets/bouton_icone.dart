import 'package:flutter/material.dart';

/*
  BoutonIcone est le widget utilisé notamment dans la barre latérale de navigation (PC) et le menu Burger (Mobile).
  Il s'agit d'un IconButton modifié qui prend en paramètre un icône et une fonction optionnelle.
  Un paramètre txt a aussi étét ajouté, qui associe une chaîne de caractères a ce bouton ; à l'avenir, ce texte devra être cliquable.
  En effet, seulement un clic sur le bouton lance la fonction associée pour le moment.
*/

class BoutonIcone extends StatelessWidget {
  final IconData icone;
  final String txt;
  final Function? fct;
  final bool selected;

  const BoutonIcone({
    super.key,
    required this.icone,
    required this.txt,
    this.fct,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected ? Colors.amber : Colors.transparent;
    final iconColor = selected ? Colors.black : Colors.white70;
    final tileColor = selected ? Colors.amber.withOpacity(0.12) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: fct == null ? null : () => fct!(),
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: Colors.amber) : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: selected ? Colors.amber : backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: selected ? null : Border.all(color: Colors.blueGrey),
                ),
                child: Icon(icone, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  txt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

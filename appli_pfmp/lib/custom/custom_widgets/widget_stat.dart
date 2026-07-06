import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:flutter/material.dart';

/*
  Ce widget est utilisé pour tous les affichages de statistiques, notamment celles de l'accueil ou de l'administrateur par exemple.
  Il prend en paramètre un icône, auquel est accompagné une statistique et un texte, faisant office de titre.
*/

class WidgetStat extends StatelessWidget {
  final IconData icone;
  final String stat;
  final String txt;

  const WidgetStat({
    super.key,
    required this.icone,
    required this.stat,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 230;

        return Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: couleurWidget,
            borderRadius: BorderRadius.circular(20),
          ),
          child: compact
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icone, color: Colors.white70, size: 34.0),
                    const SizedBox(height: 8),
                    Text(
                      stat,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      txt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(icone, color: Colors.white70, size: 42.0),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                          Text(
                            txt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

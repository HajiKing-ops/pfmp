import 'package:appli_pfmp/application/formulaire_modif_demarche.dart';
import 'package:appli_pfmp/application/formulaire_nouvelle_demarche.dart';
import 'package:appli_pfmp/bloc/demarche_bloc/demarche_bloc.dart';
import 'package:appli_pfmp/bloc/demarche_bloc/demarche_event.dart';
import 'package:appli_pfmp/bloc/demarche_bloc/demarche_state.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_texte.dart';
import 'package:appli_pfmp/custom/custom_widgets/date.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/model/demarche.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class RecherchePfmp extends StatefulWidget {
  final double lEcran;
  final double hEcran;
  final Utilisateur utilisateur;

  const RecherchePfmp({
    super.key,
    required this.lEcran,
    required this.hEcran,
    required this.utilisateur,
  });

  @override
  State<RecherchePfmp> createState() => _RecherchePfmpState();
}

class _RecherchePfmpState extends State<RecherchePfmp> {
  int saisie = 0;
  int modif = 0;
  Demarche? demarcheAModifier;

  @override
  void initState() {
    context.read<DemarcheBloc>().add(DemarcheInitializeEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DemarcheBloc, DemarcheState>(
      builder: (context, state) {
        if (state is DemarcheLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! DemarcheSuccessState) {
          return const Center(
            child: Text(
              'Veuillez rafraichir la page',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final demarches = (state.demarches ?? []).whereType<Demarche>().toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recherche d'entreprises",
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
                    ),
                    const SizedBox(height: 18),
                    _buildMapCard(),
                    const SizedBox(height: 18),
                    Expanded(
                      child: _buildDemarchesPanel(
                        demarches,
                        isNarrow: isNarrow,
                      ),
                    ),
                  ],
                ),
                if (saisie == 1)
                  _buildOverlay(
                    child: FormDemarche(
                      hEcran: MediaQuery.of(context).size.height,
                      lEcran: MediaQuery.of(context).size.width,
                      utilisateur: widget.utilisateur,
                      onClose: () {
                        setState(() {
                          saisie = 0;
                        });
                      },
                    ),
                  ),
                if (modif == 1 && demarcheAModifier != null)
                  _buildOverlay(
                    child: FormModifDemarche(
                      hEcran: MediaQuery.of(context).size.height,
                      lEcran: MediaQuery.of(context).size.width,
                      utilisateur: widget.utilisateur,
                      demarche: demarcheAModifier!,
                      onClose: () {
                        setState(() {
                          modif = 0;
                        });
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMapCard() {
    final url = Uri.parse(
      'https://www.google.com/maps/d/viewer?mid=12H6w02AHBC77923HdLshld2FbG42qSw',
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurBandeau,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Carte des entreprises partenaires',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Retrouve toutes les entreprises partenaires geolocalisees.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          BoutonTexte(
            txt: 'Ouvrir la carte',
            fct: () async {
              if (!await launchUrl(url)) {
                throw 'URL introuvable';
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDemarchesPanel(
    List<Demarche> demarches, {
    required bool isNarrow,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_in_talk_rounded, color: Colors.blueGrey),
                  SizedBox(width: 8),
                  Text(
                    'SUIVI DES DEMARCHES',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              BoutonTexte(
                txt: '+ Ajouter',
                fct: () {
                  setState(() {
                    saisie = 1;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: demarches.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune demarche enregistree',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : isNarrow
                    ? _buildDemarcheCards(demarches)
                    : _buildDemarcheTable(demarches),
          ),
        ],
      ),
    );
  }

  Widget _buildDemarcheCards(List<Demarche> demarches) {
    return ListView.separated(
      itemCount: demarches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final demarche = demarches[index];
        final couleur = _statusColor(demarche.statut);

        return Container(
          decoration: BoxDecoration(
            color: couleurBandeau,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                demarche.nomEntreprise,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                demarche.siret,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  DateFr(date: demarche.dateDemarche, couleur: Colors.white),
                  Text(
                    demarche.contact,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(demarche.statut, style: TextStyle(color: couleur)),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Modifier',
                  onPressed: () => _editDemarche(demarche),
                  icon: const Icon(Icons.mode, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDemarcheTable(List<Demarche> demarches) {
    return Column(
      children: [
        _buildTableHeader(),
        const Divider(color: Colors.amber),
        Expanded(
          child: ListView.separated(
            itemCount: demarches.length,
            separatorBuilder: (_, __) => const Divider(thickness: 0.2),
            itemBuilder: (context, index) => _buildTableRow(demarches[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Text('ENTREPRISE', style: TextStyle(color: Colors.amber)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text('DATE', style: TextStyle(color: Colors.amber)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text('CONTACT', style: TextStyle(color: Colors.amber)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text('STATUT', style: TextStyle(color: Colors.amber)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Demarche demarche) {
    final couleur = _statusColor(demarche.statut);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  demarche.nomEntreprise,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  demarche.siret,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 10.0),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DateFr(date: demarche.dateDemarche, couleur: Colors.white),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                demarche.contact,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    demarche.statut,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: couleur),
                  ),
                ),
                IconButton(
                  tooltip: 'Modifier',
                  onPressed: () => _editDemarche(demarche),
                  icon: const Icon(Icons.mode, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay({required Widget child}) {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        padding: EdgeInsets.all(Responsive.pagePadding(context)),
        child: child,
      ),
    );
  }

  void _editDemarche(Demarche demarche) {
    setState(() {
      modif = 1;
      demarcheAModifier = demarche;
    });
  }

  Color _statusColor(String statut) {
    if (statut == 'Accepte') {
      return Colors.green;
    }
    if (statut == 'Refuse') {
      return Colors.red;
    }
    return Colors.amber;
  }
}

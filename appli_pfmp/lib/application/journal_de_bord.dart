import 'package:appli_pfmp/bloc/journal_bloc/journal_bloc.dart';
import 'package:appli_pfmp/bloc/journal_bloc/journal_event.dart';
import 'package:appli_pfmp/bloc/journal_bloc/journal_state.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_state.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_texte.dart';
import 'package:appli_pfmp/custom/custom_widgets/date.dart';
import 'package:appli_pfmp/custom/custom_widgets/entree_form.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/model/journal.dart';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class JournalBord extends StatefulWidget {
  final Utilisateur utilisateur;
  final double lEcran;
  final double hEcran;

  const JournalBord({
    super.key,
    required this.utilisateur,
    required this.lEcran,
    required this.hEcran,
  });

  @override
  State<JournalBord> createState() => _JournalBordState();
}

class _JournalBordState extends State<JournalBord> {
  final _formKey = GlobalKey<FormState>();
  final activitesController = TextEditingController();
  final competencesController = TextEditingController();
  final difficultesController = TextEditingController();

  int saisie = 0;

  String get rapport =>
      '${activitesController.text}${competencesController.text}${difficultesController.text}';

  @override
  void initState() {
    context.read<EntreeJournalBloc>().add(
      EntreeJournalInitializeEvent(widget.utilisateur.id, null),
    );
    super.initState();
  }

  @override
  void dispose() {
    activitesController.dispose();
    competencesController.dispose();
    difficultesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PfmpBloc, PfmpState>(
      builder: (context, statePfmp) {
        if (statePfmp is PfmpLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (statePfmp is PfmpErrorState) {
          return Center(
            child: Text(
              statePfmp.error.toString(),
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (statePfmp is! PfmpSuccessState) {
          return const Center(
            child: Text(
              'Veuillez rafraichir la page',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final pfmps = statePfmp.pfmp.whereType<Pfmp>().toList();
        if (pfmps.isEmpty) {
          return _buildNoPfmp();
        }

        return BlocBuilder<EntreeJournalBloc, EntreeJournalState>(
          builder: (context, stateEntree) {
            if (stateEntree is EntreeJournalLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (stateEntree is EntreeJournalErrorState) {
              return Center(
                child: Text(
                  stateEntree.error.toString(),
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (stateEntree is! EntreeJournalSuccessState) {
              return const Center(
                child: Text(
                  'Veuillez rafraichir la page',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final entrees = (stateEntree.entreesJournal ?? [])
                .whereType<EntreeJournal>()
                .toList();
            return _buildJournal(pfmps.last, entrees);
          },
        );
      },
    );
  }

  Widget _buildNoPfmp() {
    return ResponsiveScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Journal de bord',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: couleurBandeau,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(14.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aucune PFMP en cours', style: TextStyle(color: Colors.amber)),
                SizedBox(height: 4),
                Text(
                  "Tu n'as aucune PFMP actuellement en cours",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                SizedBox(height: 4),
                Text(
                  "Vas dans l'onglet Recherche PFMP pour commencer a chercher des entreprises !",
                  style: TextStyle(color: Colors.amber),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildEntriesHeader(showButton: false),
        ],
      ),
    );
  }

  Widget _buildJournal(Pfmp pfmpActuelle, List<EntreeJournal> entrees) {
    final dateDebut = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(pfmpActuelle.dateDebut));
    final dateFin = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(pfmpActuelle.dateFin));

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journal de bord',
              style: TextStyle(color: Colors.white, fontSize: 25.0),
            ),
            const SizedBox(height: 20),
            _buildCurrentPfmpCard(
              pfmpActuelle,
              dateDebut,
              dateFin,
              entrees.length,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildEntriesPanel(entrees)),
          ],
        ),
        if (saisie != 0)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              padding: EdgeInsets.all(Responsive.pagePadding(context)),
              child: _buildJournalForm(isEdit: saisie == 2),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentPfmpCard(
    Pfmp pfmpActuelle,
    String dateDebut,
    String dateFin,
    int entreeCount,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurBandeau,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PFMP en cours', style: TextStyle(color: Colors.amber)),
          const SizedBox(height: 4),
          Text(
            pfmpActuelle.raisonSociale,
            style: const TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.calendar_month_rounded, color: Colors.blueGrey),
              Text(
                '$dateDebut - $dateFin - ${pfmpActuelle.nbSemaines} semaines',
                style: const TextStyle(color: Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$entreeCount jours completes - ${pfmpActuelle.joursRestants - entreeCount} restants',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesPanel(List<EntreeJournal> entrees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEntriesHeader(showButton: true),
        const SizedBox(height: 10),
        Expanded(
          child: entrees.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune entree trouvee',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: entrees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entreeJournal = entrees[index];
                    final numeroEntree = entrees.length - index;
                    return _buildEntryCard(entreeJournal, numeroEntree);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEntriesHeader({required bool showButton}) {
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Entrees du journal',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        Text(now, style: const TextStyle(color: Colors.white70)),
        if (showButton)
          BoutonTexte(
            txt: '+ Saisir',
            fct: () {
              setState(() {
                saisie = 1;
              });
            },
          ),
      ],
    );
  }

  Widget _buildEntryCard(EntreeJournal entreeJournal, int numeroEntree) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final content = [
          Text(
            numeroEntree.toString(),
            style: const TextStyle(color: Colors.amber, fontSize: 20.0),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateFr(date: entreeJournal.dateSaisie, couleur: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    entreeJournal.lienVersFichier,
                    maxLines: compact ? 4 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                saisie = 2;
              });
            },
            icon: const Icon(Icons.mode, color: Colors.black),
            label: const Text(
              'Modifier',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 31, 57, 70),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.all(12.0),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [content[0], content[1]]),
                    Align(alignment: Alignment.centerRight, child: content[2]),
                  ],
                )
              : Row(children: content),
        );
      },
    );
  }

  Widget _buildJournalForm({required bool isEdit}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: Responsive.modalWidth(context, max: 420),
        constraints: BoxConstraints(
          maxHeight: Responsive.modalHeight(context, max: 560),
        ),
        decoration: BoxDecoration(
          color: couleurFormulaire,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListView(
          padding: const EdgeInsets.all(12.0),
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isEdit ? Icons.note_alt_rounded : Icons.note_add_rounded,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text('Journal - ', style: TextStyle(color: Colors.white)),
                Flexible(
                  child: DateFr(
                    date: DateTime.now().toString(),
                    couleur: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EntreeForm(
                    txt: "CE QUE J'AI FAIT",
                    hint: 'Decris tes activites...',
                    ctrlr: activitesController,
                    obligatoire: false,
                  ),
                  EntreeForm(
                    txt: "CE QUE J'AI APPRIS",
                    hint: 'Nouvelles competences...',
                    ctrlr: competencesController,
                    obligatoire: false,
                  ),
                  EntreeForm(
                    txt: 'DIFFICULTES',
                    hint: 'Problemes rencontres...',
                    ctrlr: difficultesController,
                    obligatoire: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      saisie = 0;
                    });
                  },
                  style: const ButtonStyle(
                    side: WidgetStatePropertyAll(
                      BorderSide(color: Colors.red),
                    ),
                  ),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                BoutonTexte(txt: 'Enregistrer', fct: _submitJournal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitJournal() {
    context.read<EntreeJournalBloc>().add(
      EntreeJournalPostEvent(
        widget.utilisateur.id,
        rapport,
        DateTime.now().toString(),
      ),
    );
  }
}

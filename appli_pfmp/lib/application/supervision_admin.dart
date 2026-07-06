import 'dart:math' as math;

import 'package:appli_pfmp/bloc/infos_admin_bloc/infos_admin_bloc.dart';
import 'package:appli_pfmp/bloc/infos_admin_bloc/infos_admin_event.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_texte.dart';
import 'package:appli_pfmp/custom/custom_widgets/date.dart';
import 'package:appli_pfmp/custom/custom_widgets/widget_stat.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/presence_api.dart';
import 'package:appli_pfmp/model/infos_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupervisionAdmin extends StatefulWidget {
  final List<StagiaireAdmin> infosStagiairesAdmin;
  final StatsAdmin? statsAdmin;

  const SupervisionAdmin({
    super.key,
    required this.infosStagiairesAdmin,
    this.statsAdmin,
  });

  @override
  State<SupervisionAdmin> createState() => _SupervisionAdminState();
}

enum _PresenceDayState { present, absent, none }

class _SupervisionAdminState extends State<SupervisionAdmin> {
  List<bool> filtreStatut = [true, false, false];
  final Map<String, _PresenceDayState> _presenceSelections = {};
  final Set<int> _updatingPresencePfmps = {};
  final _rechercheController = TextEditingController();

  String recherche = '';

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  List<StagiaireAdmin> listeStagiaires(List<StagiaireAdmin> liste) {
    var filtree = liste;

    if (filtreStatut[1]) {
      filtree = filtree.where((e) => e.status == true).toList();
    } else if (filtreStatut[2]) {
      filtree = filtree.where((e) => e.status == false).toList();
    }

    if (recherche.trim().isNotEmpty) {
      final rechercheLower = recherche.trim().toLowerCase();
      filtree = filtree.where((e) {
        final nomComplet = '${e.prenom} ${e.nom}'.toLowerCase();
        return nomComplet.contains(rechercheLower);
      }).toList();
    }

    return filtree;
  }

  DateTime? _parseDate(String value) {
    return DateTime.tryParse(value);
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _dateApi(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _dateLabel(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}';
  }

  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return normalizedDate.isAfter(today);
  }

  String _dayLabel(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Lun';
      case DateTime.tuesday:
        return 'Mar';
      case DateTime.wednesday:
        return 'Mer';
      case DateTime.thursday:
        return 'Jeu';
      case DateTime.friday:
        return 'Ven';
      case DateTime.saturday:
        return 'Sam';
      case DateTime.sunday:
        return 'Dim';
    }
    return '';
  }

  int? _weekdayFromPlanningName(String jour) {
    switch (jour.trim().toLowerCase()) {
      case 'lundi':
      case 'lun':
        return DateTime.monday;
      case 'mardi':
      case 'mar':
        return DateTime.tuesday;
      case 'mercredi':
      case 'mer':
        return DateTime.wednesday;
      case 'jeudi':
      case 'jeu':
        return DateTime.thursday;
      case 'vendredi':
      case 'ven':
        return DateTime.friday;
      case 'samedi':
      case 'sam':
        return DateTime.saturday;
      case 'dimanche':
      case 'dim':
        return DateTime.sunday;
    }

    return null;
  }

  List<DateTime> _presenceDates(StagiaireAdmin stagiaire) {
    final dates = <DateTime>[];
    final seen = <String>{};

    for (final presence in stagiaire.tablePresence) {
      final parsed = _parseDate(presence.dateJour);
      if (parsed == null) {
        continue;
      }

      final date = DateTime(parsed.year, parsed.month, parsed.day);
      final key = _dateApi(date);
      if (seen.add(key)) {
        dates.add(date);
      }
    }

    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }

  List<DateTime> _stageWeekDays(StagiaireAdmin stagiaire) {
    final start = _parseDate(stagiaire.dateDebut);
    final end = _parseDate(stagiaire.dateFin);

    if (start == null || end == null || end.isBefore(start)) {
      return [];
    }

    final planningWeekdays = stagiaire.planningJours
        .map((jour) => _weekdayFromPlanningName(jour.jour))
        .whereType<int>()
        .toSet();

    if (planningWeekdays.isEmpty) {
      return _presenceDates(stagiaire);
    }

    final days = <DateTime>[];
    var current = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(last)) {
      if (planningWeekdays.contains(current.weekday)) {
        days.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  String _presenceKey(StagiaireAdmin stagiaire, DateTime date) {
    return '${stagiaire.idPfmp}:${_dateApi(date)}';
  }

  _PresenceDayState _dayState(StagiaireAdmin stagiaire, DateTime date) {
    final selectedState = _presenceSelections[_presenceKey(stagiaire, date)];
    if (selectedState != null) {
      return selectedState;
    }

    return _initialDayState(stagiaire, date);
  }

  _PresenceDayState _initialDayState(StagiaireAdmin stagiaire, DateTime date) {
    final dateApi = _dateApi(date);

    for (final presence in stagiaire.tablePresence) {
      final parsedDate = DateTime.tryParse(presence.dateJour);
      if (parsedDate == null || _dateApi(parsedDate) != dateApi) {
        continue;
      }

      final etat = presence.etat.trim().toUpperCase();
      if (etat == 'PRESENT') {
        return _PresenceDayState.present;
      }
      if (etat == 'ABSENT') {
        return _PresenceDayState.absent;
      }
    }

    return _PresenceDayState.none;
  }

  Color _dayColor(_PresenceDayState state) {
    switch (state) {
      case _PresenceDayState.present:
        return Colors.green;
      case _PresenceDayState.absent:
        return Colors.red;
      case _PresenceDayState.none:
        return couleurWidget;
    }
  }

  String _dayStatusLabel(_PresenceDayState state) {
    switch (state) {
      case _PresenceDayState.present:
        return 'Present';
      case _PresenceDayState.absent:
        return 'Absent';
      case _PresenceDayState.none:
        return '-';
    }
  }

  String _apiStatus(_PresenceDayState state) {
    return state == _PresenceDayState.absent ? 'ABSENT' : 'PRESENT';
  }

  _PresenceDayState _nextDayState(_PresenceDayState state) {
    switch (state) {
      case _PresenceDayState.present:
        return _PresenceDayState.absent;
      case _PresenceDayState.absent:
        return _PresenceDayState.none;
      case _PresenceDayState.none:
        return _PresenceDayState.present;
    }
  }

  void _cyclePresenceDate(
    StagiaireAdmin stagiaire,
    DateTime date,
    StateSetter dialogSetState,
  ) {
    final key = _presenceKey(stagiaire, date);
    final nextState = _nextDayState(_dayState(stagiaire, date));

    setState(() {
      _presenceSelections[key] = nextState;
    });
    dialogSetState(() {});
  }

  List<PresenceModification> _presenceModificationsFor(
    StagiaireAdmin stagiaire,
    List<DateTime> days,
  ) {
    final modifications = <PresenceModification>[];

    for (final date in days) {
      if (_isFutureDate(date)) {
        continue;
      }

      final key = _presenceKey(stagiaire, date);
      final state = _presenceSelections[key];

      if (state == null || state == _PresenceDayState.none) {
        continue;
      }

      modifications.add(
        PresenceModification(
          dateJour: _dateApi(date),
          etat: _apiStatus(state),
        ),
      );
    }

    return modifications;
  }

  Future<void> _updatePresenceSelections(
    StagiaireAdmin stagiaire,
    List<DateTime> days,
    StateSetter dialogSetState,
  ) async {
    final idEtudiant = stagiaire.idEtudiant;
    if (idEtudiant == null || idEtudiant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identifiant etudiant manquant dans les donnees admin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final modifications = _presenceModificationsFor(stagiaire, days);
    if (modifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun jour selectionne'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _updatingPresencePfmps.add(stagiaire.idPfmp);
    });
    dialogSetState(() {});

    final result = await modifierPresences(
      idEtudiant: idEtudiant,
      idPfmp: stagiaire.idPfmp,
      modifications: modifications,
    );
    if (!mounted) return;

    setState(() {
      _updatingPresencePfmps.remove(stagiaire.idPfmp);
    });
    dialogSetState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    if (result.success) {
      context.read<InfosAdminBloc>().add(const InfosAdminInitializeEvent());
    }
  }

  Future<void> _showPresenceDates(StagiaireAdmin stagiaire) async {
    final days = _stageWeekDays(stagiaire);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, dialogSetState) {
            return AlertDialog(
              backgroundColor: couleurFormulaire,
              title: Text(
                '${stagiaire.prenom} ${stagiaire.nom}',
                style: const TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: Responsive.modalWidth(context, max: 720),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Responsive.modalHeight(context, max: 520),
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: days.map((date) {
                        final state = _dayState(stagiaire, date);
                        final color = _dayColor(state);
                        final isFuture = _isFutureDate(date);
                        final isUpdating = _updatingPresencePfmps.contains(
                          stagiaire.idPfmp,
                        );

                        return SizedBox(
                          width: 96,
                          height: 68,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: state == _PresenceDayState.none
                                      ? Colors.grey
                                      : color,
                                ),
                              ),
                            ),
                            onPressed: isFuture || isUpdating
                                ? null
                                : () => _cyclePresenceDate(
                                      stagiaire,
                                      date,
                                      dialogSetState,
                                    ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_dayLabel(date)),
                                Text(_dateLabel(date)),
                                Text(
                                  _dayStatusLabel(state),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _updatingPresencePfmps.contains(stagiaire.idPfmp)
                      ? null
                      : () => _updatePresenceSelections(
                            stagiaire,
                            days,
                            dialogSetState,
                          ),
                  child: _updatingPresencePfmps.contains(stagiaire.idPfmp)
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Mettre a jour'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAdmin = widget.statsAdmin;
    if (statsAdmin == null) {
      return const Center(
        child: Text(
          'Statistiques indisponibles',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final stagiaires = listeStagiaires(widget.infosStagiairesAdmin);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCardLayout = constraints.maxWidth < 920;
        final compactStats = constraints.maxWidth < 650;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supervision',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            const SizedBox(height: 10),
            _buildStats(statsAdmin, compact: compactStats),
            const SizedBox(height: 10),
            _buildFilters(constraints.maxWidth),
            const SizedBox(height: 10),
            Expanded(child: _buildStudentPanel(stagiaires, isCardLayout)),
          ],
        );
      },
    );
  }

  Widget _buildStats(StatsAdmin statsAdmin, {required bool compact}) {
    final stats = [
      _AdminStatData(
        icon: Icons.book,
        stat: statsAdmin.stageTotal.toString(),
        label: 'Stages total',
      ),
      _AdminStatData(
        icon: Icons.play_circle_fill_rounded,
        stat: statsAdmin.encours.toString(),
        label: 'En cours',
      ),
      _AdminStatData(
        icon: Icons.check_box,
        stat: statsAdmin.valide.toString(),
        label: 'Valides',
      ),
      _AdminStatData(
        icon: Icons.no_accounts_rounded,
        stat: statsAdmin.absencesTotal.toString(),
        label: 'Absences totales',
      ),
    ];

    if (compact) {
      return Row(
        children: [
          for (var index = 0; index < stats.length; index++) ...[
            Expanded(child: _CompactAdminStat(data: stats[index])),
            if (index != stats.length - 1) const SizedBox(width: 6),
          ],
        ],
      );
    }

    return ResponsiveWrapGrid(
      minItemWidth: 220,
      children: [
        for (final item in stats)
          WidgetStat(icone: item.icon, stat: item.stat, txt: item.label),
      ],
    );
  }

  Widget _buildFilters(double maxWidth) {
    final searchWidth = maxWidth < 700 ? maxWidth : 320.0;

    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        BoutonTexte(
          txt: 'Tous',
          couleur: filtreStatut[0] ? Colors.amber : Colors.grey,
          fct: () {
            setState(() {
              filtreStatut = [true, false, false];
            });
          },
        ),
        BoutonTexte(
          txt: 'Valides',
          couleur: filtreStatut[1] ? Colors.amber : Colors.grey,
          fct: () {
            setState(() {
              filtreStatut = [false, true, false];
            });
          },
        ),
        BoutonTexte(
          txt: 'Incomplets',
          couleur: filtreStatut[2] ? Colors.amber : Colors.grey,
          fct: () {
            setState(() {
              filtreStatut = [false, false, true];
            });
          },
        ),
        SizedBox(
          width: searchWidth,
          height: 50,
          child: TextField(
            controller: _rechercheController,
            onChanged: (value) => setState(() => recherche = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Recherche par nom',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: recherche.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer la recherche',
                      onPressed: () {
                        _rechercheController.clear();
                        setState(() => recherche = '');
                      },
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
              filled: true,
              fillColor: couleurWidget,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.amber),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentPanel(
    List<StagiaireAdmin> stagiaires,
    bool isCardLayout,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20.0),
        color: couleurWidget,
      ),
      padding: const EdgeInsets.all(10),
      child: stagiaires.isEmpty
          ? const Center(
              child: Text('Aucun stagiaire', style: TextStyle(color: Colors.grey)),
            )
          : isCardLayout
              ? _buildCardList(stagiaires)
              : _buildTable(stagiaires),
    );
  }

  Widget _buildCardList(List<StagiaireAdmin> stagiaires) {
    return ListView.separated(
      itemCount: stagiaires.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildStudentCard(stagiaires[index]),
    );
  }

  Widget _buildStudentCard(StagiaireAdmin stagiaire) {
    final statut = _statusText(stagiaire);
    final couleurStatut = _statusColor(stagiaire);

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
            '${stagiaire.prenom} ${stagiaire.nom}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            '${stagiaire.libelleFiliere} - ${stagiaire.libelleClasse}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          _infoLine('Entreprise', stagiaire.entreprise),
          _infoLine(
            'Maitre de stage',
            '${stagiaire.prenomMaitreDeStage} ${stagiaire.nomMaitreDeStage}',
          ),
          _infoLine('Telephone', stagiaire.numTelephone),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Periode :', style: TextStyle(color: Colors.grey)),
              DateFr(date: stagiaire.dateDebut, couleur: Colors.white),
              const Text('-', style: TextStyle(color: Colors.white)),
              DateFr(date: stagiaire.dateFin, couleur: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                'Presences : ${stagiaire.presence}',
                style: const TextStyle(color: Colors.green),
              ),
              Text(
                'Absences : ${stagiaire.absence}',
                style: const TextStyle(color: Colors.red),
              ),
              Text(
                'Restants : ${stagiaire.restants}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          stagiaire.status
              ? Text(statut, style: TextStyle(color: couleurStatut))
              : BoutonTexte(
                  txt: statut,
                  couleur: couleurStatut,
                  couleurTxt: Colors.white,
                  fct: () => _showPresenceDates(stagiaire),
                ),
        ],
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(color: Colors.grey),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<StagiaireAdmin> stagiaires) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = math.max(constraints.maxWidth, 1160.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            height: constraints.maxHeight,
            child: Column(
              children: [
                _buildTableHeader(),
                const Divider(color: Colors.amber),
                Expanded(
                  child: ListView.separated(
                    itemCount: stagiaires.length,
                    separatorBuilder: (_, __) => const Divider(thickness: 0.2),
                    itemBuilder: (context, index) =>
                        _buildTableRow(stagiaires[index]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _TableHeaderCell('ELEVE'),
          _TableHeaderCell('FILIERE'),
          _TableHeaderCell('ENTREPRISE'),
          _TableHeaderCell('MAITRE DE STAGE'),
          _TableHeaderCell('PERIODE', flex: 2),
          _TableHeaderCell('PRESENCES'),
          _TableHeaderCell('ABSENCES'),
          _TableHeaderCell('RESTANTS'),
          _TableHeaderCell('STATUT'),
        ],
      ),
    );
  }

  Widget _buildTableRow(StagiaireAdmin stagiaire) {
    final statut = _statusText(stagiaire);
    final couleurStatut = _statusColor(stagiaire);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _TableCell(
            child: Text(
              '${stagiaire.prenom} ${stagiaire.nom}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          _TableCell(
            child: Column(
              children: [
                Text(
                  stagiaire.libelleFiliere,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  stagiaire.libelleClasse,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          _TableCell(
            child: Text(
              stagiaire.entreprise,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          _TableCell(
            child: Column(
              children: [
                Text(
                  '${stagiaire.prenomMaitreDeStage} ${stagiaire.nomMaitreDeStage}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  stagiaire.numTelephone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          _TableCell(
            flex: 2,
            child: Wrap(
              spacing: 4,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DateFr(date: stagiaire.dateDebut, couleur: Colors.white),
                const Text('-', style: TextStyle(color: Colors.white)),
                DateFr(date: stagiaire.dateFin, couleur: Colors.white),
              ],
            ),
          ),
          _TableCell(
            child: Text(
              stagiaire.presence.toString(),
              style: const TextStyle(color: Colors.green),
            ),
          ),
          _TableCell(
            child: Text(
              stagiaire.absence.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
          _TableCell(
            child: Text(
              stagiaire.restants.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          _TableCell(
            child: stagiaire.status
                ? Text(statut, style: TextStyle(color: couleurStatut))
                : BoutonTexte(
                    txt: statut,
                    couleur: couleurStatut,
                    couleurTxt: Colors.white,
                    fct: () => _showPresenceDates(stagiaire),
                  ),
          ),
        ],
      ),
    );
  }

  String _statusText(StagiaireAdmin stagiaire) {
    return stagiaire.status ? 'Valide' : 'Incomplet';
  }

  Color _statusColor(StagiaireAdmin stagiaire) {
    return stagiaire.status ? Colors.green : Colors.red;
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const _TableHeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.amber),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final Widget child;
  final int flex;

  const _TableCell({required this.child, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Center(child: child));
  }
}

class _AdminStatData {
  final IconData icon;
  final String stat;
  final String label;

  const _AdminStatData({
    required this.icon,
    required this.stat,
    required this.label,
  });
}

class _CompactAdminStat extends StatelessWidget {
  final _AdminStatData data;

  const _CompactAdminStat({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: Colors.white70, size: 16),
          const SizedBox(height: 2),
          Text(
            data.stat,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

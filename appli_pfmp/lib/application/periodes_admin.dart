import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/infos_admin_api.dart';
import 'package:appli_pfmp/model/admin_class_stats.dart';
import 'package:appli_pfmp/model/infos_admin.dart';
import 'package:flutter/material.dart';

class PeriodesAdmin extends StatefulWidget {
  const PeriodesAdmin({super.key});

  @override
  State<PeriodesAdmin> createState() => _PeriodesAdminState();
}

class _PeriodesAdminState extends State<PeriodesAdmin> {
  List<AdminClassStats> _classes = const [];
  List<StagiaireAdmin> _students = const [];
  AdminClassStats? _selectedClass;
  bool _loadingClasses = true;
  bool _loadingStudents = false;
  String? _classError;
  String? _studentError;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loadingClasses = true;
      _classError = null;
    });

    final result = await requestAdminClassStats();
    if (!mounted) return;

    setState(() {
      _classes = result.items;
      _loadingClasses = false;
      _classError = result.errorMessage;
      if (_selectedClass != null &&
          !_classes.any((item) =>
              item.idEtablissement == _selectedClass!.idEtablissement &&
              item.idClasse == _selectedClass!.idClasse)) {
        _selectedClass = null;
        _students = const [];
      }
    });
  }

  Future<void> _selectClass(AdminClassStats classe) async {
    setState(() {
      _selectedClass = classe;
      _students = const [];
      _studentError = null;
      _loadingStudents = true;
    });

    final result = await requestAdminStudentsByClass(
      idEtablissement: classe.idEtablissement,
      idClasse: classe.idClasse,
    );
    if (!mounted) return;

    setState(() {
      _students = result.items;
      _studentError = result.errorMessage;
      _loadingStudents = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScrollView(
      maxWidth: 1280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (_loadingClasses)
            const Center(child: CircularProgressIndicator())
          else if (_classError != null)
            _ErrorState(message: _classError!, onRetry: _loadClasses)
          else if (_classes.isEmpty)
            const _EmptyState(
              icon: Icons.school_outlined,
              message: 'Aucune classe trouvee',
            )
          else
            ResponsiveWrapGrid(
              minItemWidth: 285,
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final classe in _classes)
                  _ClassStatsCard(
                    classe: classe,
                    selected: _isSelected(classe),
                    onTap: () => _selectClass(classe),
                  ),
              ],
            ),
          if (_selectedClass != null) ...[
            const SizedBox(height: 22),
            _buildStudentsSection(_selectedClass!),
          ],
        ],
      ),
    );
  }

  bool _isSelected(AdminClassStats classe) {
    final selected = _selectedClass;
    return selected != null &&
        selected.idEtablissement == classe.idEtablissement &&
        selected.idClasse == classe.idClasse;
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Gestion des periodes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Selectionnez une classe pour consulter ses eleves en PFMP.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        );

        final refreshButton = IconButton(
          tooltip: 'Rafraichir',
          style: IconButton.styleFrom(
            backgroundColor: couleurFormulaire,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _loadingClasses ? null : _loadClasses,
          icon: const Icon(Icons.refresh_rounded),
        );

        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 10),
              refreshButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            refreshButton,
          ],
        );
      },
    );
  }

  Widget _buildStudentsSection(AdminClassStats classe) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Eleves - ${classe.displayName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _InfoChip(
                icon: Icons.school_rounded,
                label: '${classe.nombreEleves} eleves',
              ),
              if (classe.libelleFiliere.trim().isNotEmpty)
                _InfoChip(
                  icon: Icons.category_rounded,
                  label: classe.libelleFiliere,
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loadingStudents)
            const Center(child: CircularProgressIndicator())
          else if (_studentError != null)
            _ErrorState(
              message: _studentError!,
              onRetry: () => _selectClass(classe),
            )
          else if (_students.isEmpty)
            const _EmptyState(
              icon: Icons.person_search_rounded,
              message: 'Aucun etudiant trouve pour cette classe',
            )
          else
            Column(
              children: [
                for (var index = 0; index < _students.length; index++) ...[
                  _StudentCard(stagiaire: _students[index]),
                  if (index != _students.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ClassStatsCard extends StatelessWidget {
  final AdminClassStats classe;
  final bool selected;
  final VoidCallback onTap;

  const _ClassStatsCard({
    required this.classe,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalPresences = classe.presence + classe.absence;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color.fromARGB(255, 31, 56, 100) : couleurBandeau,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? Colors.amber : Colors.black),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.groups_rounded, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classe.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        classe.libelleFiliere.trim().isEmpty
                            ? 'Filiere non renseignee'
                            : classe.libelleFiliere,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _StatLine(label: 'Eleves', value: classe.nombreEleves.toString()),
            _StatLine(label: 'PFMP en cours', value: classe.enCours.toString()),
            _StatLine(label: 'Presences', value: classe.presence.toString()),
            _StatLine(label: 'Absences', value: classe.absence.toString()),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Taux de presence',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Text(
                  totalPresences == 0 ? '-' : '${classe.tauxPresence}%',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: totalPresences == 0
                    ? 0
                    : (classe.tauxPresence.clamp(0, 100) / 100),
                backgroundColor: couleurFormulaire,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StagiaireAdmin stagiaire;

  const _StudentCard({required this.stagiaire});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurBandeau,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final identity = _buildIdentity();
          final details = _buildDetails();

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 12),
                details,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: identity),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: details),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIdentity() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          child: Text(_initials(stagiaire)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stagiaire.prenom} ${stagiaire.nom}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                stagiaire.libelleClasse,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.amber),
              ),
              Text(
                stagiaire.libelleFiliere,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    final total = stagiaire.presence + stagiaire.absence;
    final tauxPresence = total == 0 ? null : (stagiaire.presence / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.business_rounded,
              label: stagiaire.entreprise.trim().isEmpty
                  ? 'Entreprise non renseignee'
                  : stagiaire.entreprise,
            ),
            _InfoChip(
              icon: Icons.person_pin_rounded,
              label: _maitreStageLabel(stagiaire),
            ),
            _InfoChip(
              icon: Icons.flag_rounded,
              label: _stageStatusLabel(stagiaire),
              color: _stageStatusColor(stagiaire),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _DetailValue(label: 'Debut PFMP', value: _formatDate(stagiaire.dateDebut)),
            _DetailValue(label: 'Fin PFMP', value: _formatDate(stagiaire.dateFin)),
            _DetailValue(
              label: 'Journal',
              value: stagiaire.status ? 'Valide' : 'Incomplet',
            ),
            _DetailValue(label: 'Presences', value: stagiaire.presence.toString()),
            _DetailValue(label: 'Absences', value: stagiaire.absence.toString()),
            _DetailValue(
              label: 'Taux',
              value: tauxPresence == null ? '-' : '$tauxPresence%',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;

  const _StatLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailValue extends StatelessWidget {
  final String label;
  final String value;

  const _DetailValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.black),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: color ?? Colors.amber,
      labelStyle: const TextStyle(color: Colors.black),
      side: BorderSide.none,
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 70, 25, 33),
        border: Border.all(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(message, style: const TextStyle(color: Colors.white)),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reessayer'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 34),
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 46),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

String _initials(StagiaireAdmin stagiaire) {
  final first = stagiaire.prenom.trim().isEmpty ? '' : stagiaire.prenom.trim()[0];
  final last = stagiaire.nom.trim().isEmpty ? '' : stagiaire.nom.trim()[0];
  final initials = '$first$last'.toUpperCase();
  return initials.isEmpty ? '?' : initials;
}

String _maitreStageLabel(StagiaireAdmin stagiaire) {
  final fullName =
      '${stagiaire.prenomMaitreDeStage} ${stagiaire.nomMaitreDeStage}'.trim();
  return fullName.isEmpty ? 'Maitre de stage non renseigne' : fullName;
}

String _formatDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value.isEmpty ? '-' : value;
  }

  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

String _stageStatusLabel(StagiaireAdmin stagiaire) {
  final start = DateTime.tryParse(stagiaire.dateDebut);
  final end = DateTime.tryParse(stagiaire.dateFin);
  if (start == null || end == null) {
    return 'PFMP non datee';
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final firstDay = DateTime(start.year, start.month, start.day);
  final lastDay = DateTime(end.year, end.month, end.day);

  if (today.isBefore(firstDay)) {
    return 'A venir';
  }
  if (today.isAfter(lastDay)) {
    return 'Terminee';
  }
  return 'En cours';
}

Color _stageStatusColor(StagiaireAdmin stagiaire) {
  switch (_stageStatusLabel(stagiaire)) {
    case 'En cours':
      return Colors.greenAccent;
    case 'A venir':
      return Colors.lightBlueAccent;
    case 'Terminee':
      return Colors.blueGrey.shade100;
  }
  return Colors.amber;
}

import 'package:appli_pfmp/application/formulaire_nouvelle_pfmp.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_state.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_texte.dart';
import 'package:appli_pfmp/custom/custom_widgets/date.dart';
import 'package:appli_pfmp/custom/custom_widgets/widget_stat.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/journal_api.dart';
import 'package:appli_pfmp/helpers/pfmp_stats.dart';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class MesPfmp extends StatefulWidget {
  final Utilisateur utilisateur;

  const MesPfmp({super.key, required this.utilisateur});

  @override
  State<MesPfmp> createState() => _MesPfmpState();
}

class _MesPfmpState extends State<MesPfmp> {
  int saisiePFMP = 0;
  int? _rapportCount;
  bool _loadingRapports = true;

  @override
  void initState() {
    super.initState();
    context.read<PfmpBloc>().add(
      PfmpInitializeEvent(widget.utilisateur.id, null),
    );
    _loadRapportStats();
  }

  Future<void> _loadRapportStats() async {
    final journal = await requestJournal(widget.utilisateur.id);
    if (!mounted) return;

    setState(() {
      _rapportCount = journal?.where((entry) => entry != null).length;
      _loadingRapports = false;
    });
  }

  Future<void> _openPfmpPdf(Pfmp pfmp) async {
    final url = Uri.base.resolve('/api/journal/pdf/${pfmp.idPfmp}');
    final launched = await launchUrl(url, webOnlyWindowName: '_blank');

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d ouvrir le PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PfmpBloc, PfmpState>(
      builder: (context, state) {
        if (state is PfmpLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PfmpErrorState) {
          return Center(
            child: Text(
              state.error.toString(),
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (state is! PfmpSuccessState) {
          return const Center(child: CircularProgressIndicator());
        }

        final pfmps = state.pfmp.whereType<Pfmp>().toList();
        final entreprisesDifferentes = pfmps.map((e) => e.siret).toSet().length;
        final heuresEntreprises = formatMinutesAsHours(
          plannedMinutesForPfmps(pfmps),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mes PFMP',
              style: TextStyle(color: Colors.white, fontSize: 25.0),
            ),
            const SizedBox(height: 12),
            ResponsiveWrapGrid(
              minItemWidth: 230,
              children: [
                WidgetStat(
                  icone: Icons.work,
                  stat: entreprisesDifferentes.toString(),
                  txt: 'Entreprises',
                ),
                WidgetStat(
                  icone: Icons.note_alt_rounded,
                  stat: heuresEntreprises,
                  txt: 'Heures en entreprise',
                ),
                WidgetStat(
                  icone: Icons.watch_later_rounded,
                  stat: _loadingRapports
                      ? '...'
                      : (_rapportCount ?? 0).toString(),
                  txt: 'Rapports',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  pfmps.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: pfmps.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _buildPfmpCard(pfmps[index]),
                        ),
                  if (saisiePFMP == 1)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black45,
                        padding: EdgeInsets.all(
                          Responsive.pagePadding(context),
                        ),
                        child: FormPfmp(
                          lEcran: MediaQuery.of(context).size.width,
                          hEcran: MediaQuery.of(context).size.height,
                          etudiant: widget.utilisateur,
                          onClose: () {
                            setState(() {
                              saisiePFMP = 0;
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Toutes mes PFMP',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        BoutonTexte(
          txt: '+ Nouvelle PFMP',
          fct: () {
            setState(() {
              saisiePFMP = 1;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPfmpCard(Pfmp pfmp) {
    final statut = pfmp.joursRestants > 0 ? 'En cours' : 'Terminee';
    final duree = statut == 'En cours'
        ? '${pfmp.nbSemaines} semaines - Jours restants : ${pfmp.joursRestants}'
        : '${pfmp.nbSemaines} semaines';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurBandeau,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('$statut :', style: const TextStyle(color: Colors.amber)),
              DateFr(date: pfmp.dateDebut, couleur: Colors.amber),
              const Text('-', style: TextStyle(color: Colors.amber)),
              DateFr(date: pfmp.dateFin, couleur: Colors.amber),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pfmp.raisonSociale,
            style: const TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          const SizedBox(height: 4),
          Text(duree, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _openPfmpPdf(pfmp),
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('PDF journal'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, color: Colors.white54, size: 60),
          SizedBox(height: 12),
          Text(
            'Aucune PFMP enregistree',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 4),
          Text(
            'Appuyez sur + Nouvelle PFMP pour commencer',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

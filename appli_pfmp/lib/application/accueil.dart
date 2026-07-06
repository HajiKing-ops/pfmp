import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_state.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_widgets/widget_stat.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/dashboard_api.dart';
import 'package:appli_pfmp/data/journal_api.dart';
import 'package:appli_pfmp/helpers/pfmp_stats.dart';
import 'package:appli_pfmp/model/dashboard.dart';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Accueil extends StatefulWidget {
  final Utilisateur currentUser;
  final double lEcran;
  final double hEcran;
  final int plateforme;
  final bool rappelsActives;
  final bool verificationRappelEnCours;
  final ValueChanged<bool>? onRappelsChanged;

  const Accueil({
    super.key,
    required this.currentUser,
    required this.lEcran,
    required this.hEcran,
    required this.plateforme,
    this.rappelsActives = false,
    this.verificationRappelEnCours = false,
    this.onRappelsChanged,
  });

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  DashboardStats? _dashboardStats;
  int? _joursRenseignes;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    context.read<PfmpBloc>().add(
      PfmpInitializeEvent(widget.currentUser.id, null),
    );
    _loadStats();
  }

  Future<void> _loadStats() async {
    final dashboardStats = await requestDashboardStats();
    final journal = await requestJournal(widget.currentUser.id);
    if (!mounted) return;

    setState(() {
      _dashboardStats = dashboardStats;
      _joursRenseignes = journal?.where((entry) => entry != null).length;
      _loadingStats = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PfmpBloc, PfmpState>(
      builder: (context, state) {
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
        final pfmpEffectuees = pfmps.length;
        final hasPfmp = pfmpEffectuees > 0;
        final dernierePfmp = hasPfmp ? pfmps.last : null;
        final joursRenseignes =
            _dashboardStats?.joursRenseignes ?? _joursRenseignes ?? 0;
        final heuresEntreprises = formatMinutesAsHours(
          plannedMinutesForPfmps(pfmps),
        );

        return ResponsiveScrollView(
          maxWidth: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildWelcomeCard(
                hasPfmp
                    ? "Tu es en PFMP chez ${dernierePfmp?.raisonSociale ?? 'ton entreprise'}. Continue a remplir ton journal chaque jour !"
                    : "Tu n'as pas de PFMP en cours. Rends-toi dans Mes PFMP pour creer ta premiere PFMP !",
              ),
              const SizedBox(height: 20),
              if (hasPfmp)
                _buildStats(
                  pfmpEffectuees: pfmpEffectuees,
                  joursRenseignes: _loadingStats
                      ? '...'
                      : joursRenseignes.toString(),
                  heuresEntreprises: _loadingStats ? '...' : heuresEntreprises,
                )
              else
                _buildEmptyState(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        side: const BorderSide(color: Colors.black),
        backgroundColor: widget.rappelsActives ? Colors.green : couleurFormulaire,
        foregroundColor: Colors.white,
      ),
      onPressed: widget.verificationRappelEnCours
          ? null
          : () => widget.onRappelsChanged?.call(!widget.rappelsActives),
      child: widget.verificationRappelEnCours
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              widget.rappelsActives ? 'Rappels actifs' : 'Activer les rappels',
            ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tableau de bord',
                style: TextStyle(color: Colors.white, fontSize: 25.0),
              ),
              const SizedBox(height: 10),
              button,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tableau de bord',
              style: TextStyle(color: Colors.white, fontSize: 25.0),
            ),
            button,
          ],
        );
      },
    );
  }

  Widget _buildWelcomeCard(String message) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurBandeau,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('BIENVENUE', style: TextStyle(color: Colors.amber)),
          const SizedBox(height: 4),
          Text(
            'Bonjour ${widget.currentUser.prenom} !',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStats({
    required int pfmpEffectuees,
    required String joursRenseignes,
    required String heuresEntreprises,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Toutes mes PFMP',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
        ResponsiveWrapGrid(
          minItemWidth: 240,
          children: [
            WidgetStat(
              icone: Icons.sticky_note_2_rounded,
              stat: pfmpEffectuees.toString(),
              txt: 'PFMP effectuees',
            ),
            WidgetStat(
              icone: Icons.note_alt_rounded,
              stat: joursRenseignes,
              txt: 'Jours renseignes',
            ),
            WidgetStat(
              icone: Icons.watch_later_rounded,
              stat: heuresEntreprises,
              txt: 'Heures en entreprise',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0),
        child: Column(
          children: const [
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
      ),
    );
  }
}

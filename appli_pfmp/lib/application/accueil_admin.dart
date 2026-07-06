import 'package:appli_pfmp/application/authentification.dart';
import 'package:appli_pfmp/application/periodes_admin.dart';
import 'package:appli_pfmp/application/messagerie_admin.dart';
import 'package:appli_pfmp/application/supervision_admin.dart';
import 'package:appli_pfmp/bloc/authentification_bloc/authentification_bloc.dart';
import 'package:appli_pfmp/bloc/authentification_bloc/authentification_event.dart';
import 'package:appli_pfmp/bloc/infos_admin_bloc/infos_admin_bloc.dart';
import 'package:appli_pfmp/bloc/infos_admin_bloc/infos_admin_event.dart';
import 'package:appli_pfmp/bloc/infos_admin_bloc/infos_admin_state.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/authentification_api.dart';
import 'package:appli_pfmp/data/presence_api.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccueilAdmin extends StatefulWidget {
  final Utilisateur utilisateur;

  const AccueilAdmin({super.key, required this.utilisateur});

  @override
  State<AccueilAdmin> createState() => _AccueilAdminState();
}

class _AccueilAdminState extends State<AccueilAdmin> {
  static const _background = Color.fromARGB(255, 13, 28, 54);

  bool _isInitializingPresence = false;
  int onglet = 1;

  @override
  void initState() {
    super.initState();
    context.read<InfosAdminBloc>().add(const InfosAdminInitializeEvent());
  }

  void _selectOnglet(int value, {bool closeDrawer = false}) {
    setState(() {
      onglet = value;
    });

    if (closeDrawer) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _disconnect() async {
    await logout();
    if (!mounted) return;

    context.read<AuthentificationBloc>().add(
      const AuthentificationLogoutEvent(),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PageAuth()),
      (route) => false,
    );
  }

  Future<void> _initializePresences() async {
    if (_isInitializingPresence) {
      return;
    }

    setState(() {
      _isInitializingPresence = true;
    });

    final result = await initialiserPresences();
    if (!mounted) return;

    setState(() {
      _isInitializingPresence = false;
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      drawer: _buildAdminDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          child: BlocBuilder<InfosAdminBloc, InfosAdminState>(
            builder: (context, state) {
              if (state is InfosAdminLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is InfosAdminErrorState) {
                return Center(
                  child: Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              if (state is! InfosAdminSuccessState) {
                return Column(
                  children: [
                    const Text(
                      'BlocBuilder - Veuillez rafraichir la page',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      state.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        switch (onglet) {
                          case 1:
                            return SupervisionAdmin(
                              infosStagiairesAdmin:
                                  state.infosStagiairesAdmin,
                              statsAdmin: state.statsAdmin,
                            );
                          case 2:
                            return const PeriodesAdmin();
                          case 3:
                            return MessagerieAdmin(
                              utilisateur: widget.utilisateur,
                              stagiaires: state.infosStagiairesAdmin,
                            );
                        }
                        return const Text(
                          'Probleme builder',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final menuButton = Builder(
            builder: (buttonContext) {
              return IconButton(
                tooltip: 'Menu admin',
                style: IconButton.styleFrom(
                  backgroundColor: couleurFormulaire,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Scaffold.of(buttonContext).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              );
            },
          );
          final title = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person_rounded, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Espace Administrateur',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 20.0 : 25.0,
                  ),
                ),
              ),
            ],
          );

          if (compact) {
            return Row(
              children: [
                menuButton,
                const SizedBox(width: 10),
                Expanded(child: title),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              menuButton,
              const SizedBox(width: 10),
              Flexible(child: title),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: _background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    child: Icon(Icons.lock_person_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.utilisateur.prenom} ${widget.utilisateur.nom}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.blueGrey),
            _AdminDrawerButton(
              icon: Icons.dashboard_rounded,
              label: 'Supervision',
              selected: onglet == 1,
              onPressed: () => _selectOnglet(1, closeDrawer: true),
            ),
            _AdminDrawerButton(
              icon: Icons.date_range_rounded,
              label: 'Gestion des periodes',
              selected: onglet == 2,
              onPressed: () => _selectOnglet(2, closeDrawer: true),
            ),
            _AdminDrawerButton(
              icon: Icons.forum_rounded,
              label: 'Messagerie',
              selected: onglet == 3,
              onPressed: () => _selectOnglet(3, closeDrawer: true),
            ),
            _AdminDrawerButton(
              icon: Icons.fact_check_rounded,
              label: _isInitializingPresence
                  ? 'Initialisation...'
                  : 'Initialiser presences',
              onPressed: _isInitializingPresence
                  ? null
                  : () {
                      Navigator.of(context).maybePop();
                      _initializePresences();
                    },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _disconnect,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Deconnexion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDrawerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  const _AdminDrawerButton({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: selected ? Colors.amber : couleurWidget,
          foregroundColor: selected ? Colors.black : Colors.white,
          disabledBackgroundColor: couleurWidget.withOpacity(0.6),
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

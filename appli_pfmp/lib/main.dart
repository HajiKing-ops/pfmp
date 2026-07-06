import 'dart:async';
import 'dart:math' as math;

import 'package:appli_pfmp/application/accueil.dart';
import 'package:appli_pfmp/application/accueil_admin.dart';
import 'package:appli_pfmp/application/authentification.dart';
import 'package:appli_pfmp/application/journal_de_bord.dart';
import 'package:appli_pfmp/application/mes_pfmp.dart';
import 'package:appli_pfmp/application/messagerie.dart';
import 'package:appli_pfmp/application/mon_profil.dart';
import 'package:appli_pfmp/application/recherche_pfmp.dart';
import 'package:appli_pfmp/bloc/authentification_bloc/authentification_bloc.dart';
import 'package:appli_pfmp/bloc/authentification_bloc/authentification_event.dart';
import 'package:appli_pfmp/bloc/demarche_bloc/demarche_bloc.dart';
import 'package:appli_pfmp/bloc/infos_admin_bloc/infos_admin_bloc.dart';
import 'package:appli_pfmp/bloc/journal_bloc/journal_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/custom/custom_widgets/app_logo.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_icone.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/authentification_api.dart';
import 'package:appli_pfmp/data/journal_api.dart';
import 'package:appli_pfmp/data/journal_reminder_storage.dart';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthentificationBloc>(
          create: (_) => AuthentificationBloc(),
        ),
        BlocProvider<PfmpBloc>(create: (_) => PfmpBloc()),
        BlocProvider<EntreeJournalBloc>(create: (_) => EntreeJournalBloc()),
        BlocProvider<DemarcheBloc>(create: (_) => DemarcheBloc()),
        BlocProvider<InfosAdminBloc>(create: (_) => InfosAdminBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('fr')],
        theme: ThemeData(fontFamily: 'Syne'),
        home: const PageAuth(),
      ),
    ),
  );
}

class PfmpManager extends StatefulWidget {
  final Utilisateur? currentUser;
  final Pfmp? pfmp;

  const PfmpManager({super.key, this.currentUser, this.pfmp});

  @override
  State<PfmpManager> createState() => _PfmpManagerState();
}

class _PfmpManagerState extends State<PfmpManager> {
  static const _appBackground = Color.fromARGB(255, 15, 31, 61);
  static const _navBackground = Color.fromARGB(255, 13, 28, 54);

  int numPage = 0;
  bool _journalRemindersEnabled = false;
  bool _checkingJournalReminder = false;
  bool _journalAlertDialogOpen = false;
  Timer? _journalReminderTimer;

  final List<_NavItem> _navigationItems = const [
    _NavItem(Icons.house_rounded, 'Accueil', 0),
    _NavItem(Icons.search, 'Recherche PFMP', 1),
    _NavItem(Icons.note_alt_rounded, 'Journal de bord', 2),
    _NavItem(Icons.chat_bubble, 'Messagerie', 3),
    _NavItem(Icons.folder_copy_rounded, 'Mes PFMP', 4),
  ];

  final List<_NavItem> _accountItems = const [
    _NavItem(Icons.person, 'Mon profil', 5),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJournalReminderPreference();
    });
  }

  @override
  void dispose() {
    _journalReminderTimer?.cancel();
    super.dispose();
  }

  Future<void> _disconnect() async {
    _journalReminderTimer?.cancel();
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

  void _loadJournalReminderPreference() {
    final user = widget.currentUser;
    if (!mounted || user == null || user.role != 'Etudiant') {
      return;
    }

    final enabled = readJournalReminderEnabled(user.id);
    setState(() {
      _journalRemindersEnabled = enabled;
    });

    if (enabled) {
      _startJournalReminderTimer();
      _checkJournalReminder(force: true);
    }
  }

  Future<void> _setJournalReminderEnabled(bool enabled) async {
    final user = widget.currentUser;
    if (user == null || user.role != 'Etudiant') {
      return;
    }

    writeJournalReminderEnabled(user.id, enabled);
    if (!mounted) return;

    setState(() {
      _journalRemindersEnabled = enabled;
    });

    if (enabled) {
      _startJournalReminderTimer();
      await _checkJournalReminder(force: true, showErrors: true);
    } else {
      _journalReminderTimer?.cancel();
      _journalReminderTimer = null;
    }
  }

  void _startJournalReminderTimer() {
    _journalReminderTimer?.cancel();
    _journalReminderTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _checkJournalReminder();
    });
  }

  Future<void> _checkJournalReminder({
    bool force = false,
    bool showErrors = false,
  }) async {
    final user = widget.currentUser;
    if (user == null || user.role != 'Etudiant') {
      return;
    }

    if (!_journalRemindersEnabled && !force) {
      return;
    }

    final today = _dateKey(DateTime.now());
    if (!force) {
      final now = DateTime.now();
      final alreadyChecked =
          readLastJournalReminderCheckDate(user.id) == today;
      if (now.hour < 12 || alreadyChecked) {
        return;
      }
    }

    if (_checkingJournalReminder) {
      return;
    }

    setState(() {
      _checkingJournalReminder = true;
    });

    final result = await checkJournalAlerte();
    if (!mounted) return;

    setState(() {
      _checkingJournalReminder = false;
    });

    if (!result.success) {
      if (showErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
      return;
    }

    writeLastJournalReminderCheckDate(user.id, today);

    if (result.journalExiste) {
      return;
    }

    writeLastJournalReminderAlertDate(user.id, today);
    await _showJournalReminderDialog(result.message);
  }

  Future<void> _showJournalReminderDialog(String message) async {
    if (_journalAlertDialogOpen || !mounted) {
      return;
    }

    _journalAlertDialogOpen = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Journal de bord'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    _journalAlertDialogOpen = false;
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _selectPage(int page, {bool closeDrawer = false}) {
    setState(() {
      numPage = page;
    });
    if (closeDrawer) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: _appBackground,
        body: Center(
          child: Text(
            'Utilisateur inconnu',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (user.role == 'Administrateur') {
      return AccueilAdmin(utilisateur: user);
    }

    if (user.role != 'Etudiant') {
      return const Scaffold(
        backgroundColor: _appBackground,
        body: Center(
          child: Text(
            'Utilisateur inconnu',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Responsive.isDesktop(context)
        ? _buildDesktopStudentShell(context, user)
        : _buildCompactStudentShell(context, user);
  }

  Widget _buildDesktopStudentShell(BuildContext context, Utilisateur user) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = math.min(280.0, math.max(230.0, screenWidth * 0.18));

    return Scaffold(
      backgroundColor: _appBackground,
      body: Row(
        children: [
          SizedBox(
            width: sidebarWidth,
            child: _buildSidebar(context, user),
          ),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(Responsive.pagePadding(context)),
                child: _buildStudentPage(context, user),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStudentShell(BuildContext context, Utilisateur user) {
    return Scaffold(
      backgroundColor: _appBackground,
      appBar: AppBar(
        toolbarHeight: 76,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: _navBackground,
        titleSpacing: 0,
        title: _buildBrand(compact: true),
      ),
      drawer: Drawer(
        backgroundColor: _navBackground,
        width: math.min(320.0, MediaQuery.of(context).size.width * 0.88),
        child: SafeArea(child: _buildNavigationContent(user, closeDrawer: true)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          child: _buildStudentPage(context, user),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, Utilisateur user) {
    return Container(
      decoration: const BoxDecoration(
        color: _navBackground,
        border: Border(right: BorderSide(color: Colors.blueGrey)),
      ),
      child: SafeArea(child: _buildNavigationContent(user)),
    );
  }

  Widget _buildNavigationContent(
    Utilisateur user, {
    bool closeDrawer = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBrand(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionLabel('NAVIGATION'),
                for (final item in _navigationItems)
                  BoutonIcone(
                    icone: item.icon,
                    txt: item.label,
                    selected: numPage == item.page,
                    fct: () => _selectPage(
                      item.page,
                      closeDrawer: closeDrawer,
                    ),
                  ),
                const Divider(color: Colors.blueGrey),
                _buildSectionLabel('COMPTE'),
                for (final item in _accountItems)
                  BoutonIcone(
                    icone: item.icon,
                    txt: item.label,
                    selected: numPage == item.page,
                    fct: () => _selectPage(
                      item.page,
                      closeDrawer: closeDrawer,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: _disconnect,
                    icon: const Icon(Icons.logout),
                    label: const Text('Deconnexion'),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildProfileFooter(user),
      ],
    );
  }

  Widget _buildBrand({bool compact = false}) {
    final logoHeight = compact ? 52.0 : 118.0;
    final logoMaxWidth = compact ? 118.0 : 224.0;

    if (!compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppLogo(height: logoHeight, maxWidth: logoMaxWidth),
          ),
          const SizedBox(height: 10),
          const Text(
            'PFMP Manager',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Cite Scolaire Jamot-Jaures',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.amber, fontSize: 12),
          ),
        ],
      );
    }

    return Row(
      children: [
        AppLogo(height: logoHeight, maxWidth: logoMaxWidth),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PFMP Manager',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Cite Scolaire Jamot-Jaures',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
      child: Text(
        label,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildProfileFooter(Utilisateur user) {
    final prenomInitial = user.prenom.isNotEmpty ? user.prenom[0] : '?';
    final nomInitial = user.nom.isNotEmpty ? user.nom[0] : '?';

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.blueGrey)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            child: Text('$prenomInitial$nomInitial'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${user.prenom} ${user.nom}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  user.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentPage(BuildContext context, Utilisateur user) {
    final hEcran = MediaQuery.of(context).size.height;
    final lEcran = MediaQuery.of(context).size.width;
    final plateforme = Responsive.platformCode(context);

    switch (numPage) {
      case 0:
        return Accueil(
          currentUser: user,
          lEcran: lEcran,
          hEcran: hEcran,
          plateforme: plateforme,
          rappelsActives: _journalRemindersEnabled,
          verificationRappelEnCours: _checkingJournalReminder,
          onRappelsChanged: _setJournalReminderEnabled,
        );
      case 1:
        return RecherchePfmp(
          hEcran: hEcran,
          lEcran: lEcran,
          utilisateur: user,
        );
      case 2:
        return JournalBord(
          utilisateur: user,
          hEcran: hEcran,
          lEcran: lEcran,
        );
      case 3:
        return Messagerie(
          hEcran: hEcran,
          lEcran: lEcran,
          utilisateur: user,
        );
      case 4:
        return MesPfmp(utilisateur: user);
      case 5:
        return MonProfil(hEcran: hEcran, lEcran: lEcran, utilisateur: user);
      case 6:
      case 10:
        return const PageAuth();
      default:
        return Accueil(
          currentUser: user,
          lEcran: lEcran,
          hEcran: hEcran,
          plateforme: plateforme,
          rappelsActives: _journalRemindersEnabled,
          verificationRappelEnCours: _checkingJournalReminder,
          onRappelsChanged: _setJournalReminderEnabled,
        );
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int page;

  const _NavItem(this.icon, this.label, this.page);
}

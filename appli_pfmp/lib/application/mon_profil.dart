import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/profile_api.dart';
import 'package:appli_pfmp/model/profile.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';

class MonProfil extends StatefulWidget {
  final double lEcran;
  final double hEcran;
  final Utilisateur utilisateur;

  const MonProfil({
    super.key,
    required this.lEcran,
    required this.hEcran,
    required this.utilisateur,
  });

  @override
  State<MonProfil> createState() => _MonProfilState();
}

class _MonProfilState extends State<MonProfil> {
  StudentProfile? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await requestProfileMe();
    if (!mounted) return;

    setState(() {
      _profile = result.profile;
      _error = result.errorMessage;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = _profile;

    return ResponsiveScrollView(
      maxWidth: 1120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (_error != null) _buildErrorCard(_error!),
          if (profile != null) ...[
            if (_error != null) const SizedBox(height: 12),
            _ProfileHero(profile: profile),
            const SizedBox(height: 16),
            _ProfileSummary(profile: profile),
            const SizedBox(height: 16),
            ResponsiveWrapGrid(
              minItemWidth: 245,
              spacing: 12,
              runSpacing: 12,
              children: [
                _ProfileInfoCard(
                  icon: Icons.badge_rounded,
                  label: 'Prenom',
                  value: profile.prenom,
                ),
                _ProfileInfoCard(
                  icon: Icons.person_rounded,
                  label: 'Nom',
                  value: profile.nom,
                ),
                _ProfileInfoCard(
                  icon: Icons.cake_rounded,
                  label: 'Date de naissance',
                  value: profile.dateNaissance,
                ),
                _ProfileInfoCard(
                  icon: Icons.school_rounded,
                  label: 'Niveau',
                  value: profile.niveau,
                ),
                _ProfileInfoCard(
                  icon: Icons.category_rounded,
                  label: 'Filiere',
                  value: profile.filiere,
                ),
                _ProfileInfoCard(
                  icon: Icons.location_city_rounded,
                  label: 'Etablissement',
                  value: profile.etablissement,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Mon profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tes informations scolaires et personnelles.',
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
          onPressed: _loadProfile,
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

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 69, 24, 32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent),
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(message, style: const TextStyle(color: Colors.white)),
          OutlinedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reessayer'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final StudentProfile profile;

  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 32, 68, 126),
            Color.fromARGB(255, 18, 37, 73),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final avatar = CircleAvatar(
            radius: compact ? 38 : 48,
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            child: Text(
              profile.initials,
              style: TextStyle(
                fontSize: compact ? 24 : 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
          final text = Column(
            crossAxisAlignment:
                compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName.isEmpty ? 'Profil etudiant' : profile.fullName,
                textAlign: compact ? TextAlign.center : TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                profile.niveau.isEmpty ? 'Niveau non renseigne' : profile.niveau,
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(color: Colors.amber, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                profile.etablissement.isEmpty
                    ? 'Etablissement non renseigne'
                    : profile.etablissement,
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          );

          if (compact) {
            return Column(
              children: [
                avatar,
                const SizedBox(height: 14),
                text,
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 18),
              Expanded(child: text),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  final StudentProfile profile;

  const _ProfileSummary({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurWidget,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ProfileChip(icon: Icons.school_rounded, label: profile.filiere),
          _ProfileChip(
            icon: Icons.location_city_rounded,
            label: profile.etablissement,
          ),
          _ProfileChip(
            icon: Icons.cake_rounded,
            label: profile.dateNaissance,
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      decoration: BoxDecoration(
        color: couleurBandeau,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 5),
                Text(
                  value.trim().isEmpty ? 'Non renseigne' : value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.black, size: 16),
      label: Text(label.trim().isEmpty ? 'Non renseigne' : label),
      backgroundColor: Colors.amber,
      labelStyle: const TextStyle(color: Colors.black),
      side: BorderSide.none,
    );
  }
}

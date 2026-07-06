import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_functions/calculs_horaires.dart';
import 'package:appli_pfmp/custom/custom_functions/format_planning.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_texte.dart';
import 'package:appli_pfmp/custom/custom_widgets/entree_form.dart';
import 'package:appli_pfmp/custom/custom_widgets/entree_horaire.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormPfmp extends StatefulWidget {
  final double lEcran;
  final double hEcran;
  final Utilisateur etudiant;
  final VoidCallback onClose;

  const FormPfmp({
    super.key,
    required this.lEcran,
    required this.hEcran,
    required this.etudiant,
    required this.onClose,
  });

  @override
  State<FormPfmp> createState() => _FormPfmpState();
}

class _FormPfmpState extends State<FormPfmp> {
  static const _inactiveDayColor = Color.fromARGB(255, 48, 0, 131);

  final _formKey = GlobalKey<FormState>();
  final nomEntrepriseController = TextEditingController();
  final secteurEntrepriseController = TextEditingController();
  final siretController = TextEditingController();
  final adresseController = TextEditingController();
  final telephoneEntrepriseController = TextEditingController();
  final siteWebController = TextEditingController();
  final prenomMaitreController = TextEditingController();
  final nomMaitreController = TextEditingController();
  final fonctionMaitreController = TextEditingController();
  final telephoneMaitreController = TextEditingController();
  final emailMaitreController = TextEditingController();

  bool lunIsPressed = false;
  bool marIsPressed = false;
  bool merIsPressed = false;
  bool jeuIsPressed = false;
  bool venIsPressed = false;
  bool samIsPressed = false;
  bool dimIsPressed = false;

  final Map<String, Map<String, TextEditingController>> controllersHoraires =
      {};

  TextEditingController _getController(String jour, String creneau) {
    controllersHoraires.putIfAbsent(jour, () => {});
    return controllersHoraires[jour]!.putIfAbsent(
      creneau,
      () => TextEditingController(),
    );
  }

  void _clearJour(String jour) {
    final jourMap = controllersHoraires.remove(jour);
    if (jourMap != null) {
      for (final controller in jourMap.values) {
        controller.dispose();
      }
    }
  }

  @override
  void dispose() {
    nomEntrepriseController.dispose();
    secteurEntrepriseController.dispose();
    siretController.dispose();
    adresseController.dispose();
    telephoneEntrepriseController.dispose();
    siteWebController.dispose();
    prenomMaitreController.dispose();
    nomMaitreController.dispose();
    fonctionMaitreController.dispose();
    telephoneMaitreController.dispose();
    emailMaitreController.dispose();
    for (final jourMap in controllersHoraires.values) {
      for (final controller in jourMap.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joursSelect = <String, bool>{
      'Lundi': lunIsPressed,
      'Mardi': marIsPressed,
      'Mercredi': merIsPressed,
      'Jeudi': jeuIsPressed,
      'Vendredi': venIsPressed,
      'Samedi': samIsPressed,
      'Dimanche': dimIsPressed,
    };

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: Responsive.modalWidth(context, max: 720),
        constraints: BoxConstraints(
          maxHeight: Responsive.modalHeight(context, max: 680),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15.0),
          color: couleurFormulaire,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12.0),
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drive_file_move_rounded, color: Colors.grey),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Creer une nouvelle PFMP',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionTitle(Icons.work, 'ENTREPRISE'),
              EntreeForm(
                txt: 'NOM *',
                hint: 'Ex : Boutique Mode Aubusson',
                ctrlr: nomEntrepriseController,
                obligatoire: true,
              ),
              ResponsiveFormRow(
                children: [
                  EntreeForm(
                    txt: 'SECTEUR *',
                    hint: 'Ex : Mode',
                    ctrlr: secteurEntrepriseController,
                    obligatoire: true,
                  ),
                  EntreeForm(
                    txt: 'SIRET *',
                    hint: '123 456 789',
                    ctrlr: siretController,
                    obligatoire: true,
                  ),
                ],
              ),
              EntreeForm(
                txt: 'ADRESSE',
                hint: 'Numero, rue, code postal, ville',
                ctrlr: adresseController,
                obligatoire: false,
              ),
              ResponsiveFormRow(
                children: [
                  EntreeForm(
                    txt: 'TELEPHONE *',
                    hint: '01 23 45 67 89',
                    ctrlr: telephoneEntrepriseController,
                    obligatoire: true,
                  ),
                  EntreeForm(
                    txt: 'SITE WEB',
                    hint: 'https://...',
                    ctrlr: siteWebController,
                    obligatoire: false,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _sectionTitle(Icons.person, 'MAITRE DE STAGE'),
              ResponsiveFormRow(
                children: [
                  EntreeForm(
                    txt: 'PRENOM *',
                    hint: 'Ex : Martin',
                    ctrlr: prenomMaitreController,
                    obligatoire: true,
                  ),
                  EntreeForm(
                    txt: 'NOM *',
                    hint: 'Ex : Dupont',
                    ctrlr: nomMaitreController,
                    obligatoire: true,
                  ),
                ],
              ),
              ResponsiveFormRow(
                children: [
                  EntreeForm(
                    txt: 'FONCTION',
                    hint: 'Ex : Responsable',
                    ctrlr: fonctionMaitreController,
                    obligatoire: false,
                  ),
                  EntreeForm(
                    txt: 'TELEPHONE',
                    hint: '01 23 45 67 89',
                    ctrlr: telephoneMaitreController,
                    obligatoire: false,
                  ),
                ],
              ),
              EntreeForm(
                txt: 'EMAIL *',
                hint: 'Ex : martin.dupont@entreprise.fr',
                ctrlr: emailMaitreController,
                obligatoire: true,
              ),
              const SizedBox(height: 10),
              _sectionTitle(Icons.date_range_rounded, 'PERIODE'),
              const Text('Du {} au {}', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              const Text(
                'JOURS TRAVAILLES',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 6),
              _buildDayButtons(),
              const SizedBox(height: 12),
              const Text('HORAIRES', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              _buildHours(joursSelect),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.amber)),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildDayButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _dayButton('Lun', lunIsPressed, () {
          setState(() {
            lunIsPressed = !lunIsPressed;
            if (!lunIsPressed) _clearJour('Lundi');
          });
        }),
        _dayButton('Mar', marIsPressed, () {
          setState(() {
            marIsPressed = !marIsPressed;
            if (!marIsPressed) _clearJour('Mardi');
          });
        }),
        _dayButton('Mer', merIsPressed, () {
          setState(() {
            merIsPressed = !merIsPressed;
            if (!merIsPressed) _clearJour('Mercredi');
          });
        }),
        _dayButton('Jeu', jeuIsPressed, () {
          setState(() {
            jeuIsPressed = !jeuIsPressed;
            if (!jeuIsPressed) _clearJour('Jeudi');
          });
        }),
        _dayButton('Ven', venIsPressed, () {
          setState(() {
            venIsPressed = !venIsPressed;
            if (!venIsPressed) _clearJour('Vendredi');
          });
        }),
        _dayButton('Sam', samIsPressed, () {
          setState(() {
            samIsPressed = !samIsPressed;
            if (!samIsPressed) _clearJour('Samedi');
          });
        }),
        _dayButton('Dim', dimIsPressed, () {
          setState(() {
            dimIsPressed = !dimIsPressed;
            if (!dimIsPressed) _clearJour('Dimanche');
          });
        }),
      ],
    );
  }

  Widget _dayButton(String label, bool selected, VoidCallback onPressed) {
    return SizedBox(
      width: 76,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: const BorderSide(color: Colors.black),
          backgroundColor: selected ? Colors.amber : _inactiveDayColor,
          foregroundColor: selected ? Colors.black : Colors.white,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  Widget _buildHours(Map<String, bool> joursSelect) {
    final joursActifs = joursSelect.entries
        .where((element) => element.value)
        .map((e) => e.key)
        .toList();

    if (joursActifs.isEmpty) {
      return const Text(
        'Veuillez selectionner des jours',
        style: TextStyle(color: Colors.red),
      );
    }

    return Column(
      children: [
        for (final jour in joursActifs) _buildHourCard(jour),
      ],
    );
  }

  Widget _buildHourCard(String jour) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(15.0),
        color: couleurBandeau,
      ),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              jour,
              style: const TextStyle(color: Colors.amber, fontSize: 15.0),
            ),
          ),
          const SizedBox(height: 8),
          ResponsiveFormRow(
            breakpoint: 620,
            spacing: 16,
            children: [
              _timeSlot(jour, 'Matin', 'matinDebut', 'matinFin'),
              _timeSlot(
                jour,
                'Apres-midi',
                'apresMidiDebut',
                'apresMidiFin',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total : ${totalHoraires(
                horairesMatin: [
                  _getController(jour, 'matinDebut').text,
                  _getController(jour, 'matinFin').text,
                ],
                horairesApresMidi: [
                  _getController(jour, 'apresMidiDebut').text,
                  _getController(jour, 'apresMidiFin').text,
                ],
              )}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeSlot(
    String jour,
    String label,
    String debutKey,
    String finKey,
  ) {
    final isMorning = label == 'Matin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Row(
          children: [
            Expanded(
              child: EntreeHoraire(
                hint: isMorning ? '08:00' : '14:00',
                ctrlr: _getController(jour, debutKey),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('-', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            Expanded(
              child: EntreeHoraire(
                hint: isMorning ? '12:00' : '18:00',
                ctrlr: _getController(jour, finKey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        TextButton(
          onPressed: widget.onClose,
          style: const ButtonStyle(
            side: WidgetStatePropertyAll(BorderSide(color: Colors.red)),
          ),
          child: const Text('Annuler', style: TextStyle(color: Colors.red)),
        ),
        BoutonTexte(txt: 'Enregistrer', fct: _submit),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final horaires = <String, Map<String, String?>>{};
    for (final jourEntry in controllersHoraires.entries) {
      final creneaux = <String, String?>{};
      for (final creneauEntry in jourEntry.value.entries) {
        creneaux[creneauEntry.key] = creneauEntry.value.text.isEmpty
            ? null
            : creneauEntry.value.text;
      }
      horaires[jourEntry.key] = creneaux;
    }

    final infosPfmp = {
      'raisonSociale': nomEntrepriseController.text,
      'secteurActivite': secteurEntrepriseController.text,
      'siret': siretController.text,
      'adresse': adresseController.text,
      'numTelephone': telephoneEntrepriseController.text,
      'totalHebdo': totalHebdo(formatApiPlanning(horaires)),
      'planningJours': formatApiPlanning(horaires),
      'dateDebut': '2026-08-20',
      'dateFin': '2026-09-20',
      'idEtudiant': widget.etudiant.id,
      'prenomMaitreStage': prenomMaitreController.text,
      'nomMaitreStage': nomMaitreController.text,
      'fonctionMaitreStage': fonctionMaitreController.text,
      'telephoneMaitreStage': telephoneMaitreController.text,
      'emailMaitreStage': emailMaitreController.text,
    };

    context.read<PfmpBloc>().add(PfmpPostEvent(infosPfmp));
  }
}

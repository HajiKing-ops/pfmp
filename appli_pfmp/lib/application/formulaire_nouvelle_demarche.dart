import 'package:appli_pfmp/bloc/demarche_bloc/demarche_bloc.dart';
import 'package:appli_pfmp/bloc/demarche_bloc/demarche_event.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_functions/selection_date.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_texte.dart';
import 'package:appli_pfmp/custom/custom_widgets/date.dart';
import 'package:appli_pfmp/custom/custom_widgets/entree_form.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormDemarche extends StatefulWidget {
  final double hEcran;
  final double lEcran;
  final Utilisateur utilisateur;
  final VoidCallback onClose;

  const FormDemarche({
    super.key,
    required this.hEcran,
    required this.lEcran,
    required this.utilisateur,
    required this.onClose,
  });

  @override
  State<FormDemarche> createState() => _FormDemarcheState();
}

class _FormDemarcheState extends State<FormDemarche> {
  final _formKey = GlobalKey<FormState>();

  final nomEntrepriseController = TextEditingController();
  final siretEntrepriseController = TextEditingController();
  final contactEntrepriseController = TextEditingController();

  DateTime dateContact = DateTime.now();

  @override
  void dispose() {
    nomEntrepriseController.dispose();
    siretEntrepriseController.dispose();
    contactEntrepriseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: Responsive.modalWidth(context, max: 520),
        constraints: BoxConstraints(
          maxHeight: Responsive.modalHeight(context, max: 560),
        ),
        decoration: BoxDecoration(
          color: couleurFormulaire,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12.0),
            shrinkWrap: true,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_forwarded_rounded, color: Colors.grey),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Enregistrer une demarche',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              EntreeForm(
                txt: 'NOM ENTREPRISE',
                hint: "Nom de l'entreprise",
                ctrlr: nomEntrepriseController,
                obligatoire: false,
              ),
              EntreeForm(
                txt: 'SIRET *',
                hint: '123 456 789',
                ctrlr: siretEntrepriseController,
                obligatoire: true,
              ),
              _buildDatePicker(),
              EntreeForm(
                txt: 'CONTACT *',
                hint: 'Coordonnees (telephone, email...)',
                ctrlr: contactEntrepriseController,
                obligatoire: true,
              ),
              const SizedBox(height: 8),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DATE *', style: TextStyle(color: Colors.grey)),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Date :', style: TextStyle(color: Colors.blueGrey)),
              DateFr(date: dateContact.toString(), couleur: Colors.white),
              TextButton.icon(
                onPressed: () async {
                  final nouvelleDate = await dateSelectionnee(
                    context,
                    dateContact,
                    true,
                  );
                  if (nouvelleDate != null) {
                    setState(() {
                      dateContact = nouvelleDate;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Changer'),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
              ),
            ],
          ),
        ],
      ),
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
        BoutonTexte(
          txt: 'Enregistrer',
          fct: () {
            if (_formKey.currentState!.validate()) {
              context.read<DemarcheBloc>().add(
                DemarchePostEvent(
                  nomEntrepriseController.text,
                  siretEntrepriseController.text,
                  dateContact.toString(),
                  contactEntrepriseController.text,
                  'En attente',
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

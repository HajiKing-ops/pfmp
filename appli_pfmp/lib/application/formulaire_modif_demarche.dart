import 'package:appli_pfmp/bloc/demarche_bloc/demarche_bloc.dart';
import 'package:appli_pfmp/bloc/demarche_bloc/demarche_event.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_functions/selection_date.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_statut.dart';
import 'package:appli_pfmp/custom/custom_widgets/bouton_texte.dart';
import 'package:appli_pfmp/custom/custom_widgets/date.dart';
import 'package:appli_pfmp/custom/custom_widgets/entree_form.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/model/demarche.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormModifDemarche extends StatefulWidget {
  final double hEcran;
  final double lEcran;
  final Utilisateur utilisateur;
  final Demarche demarche;
  final VoidCallback onClose;

  const FormModifDemarche({
    super.key,
    required this.hEcran,
    required this.lEcran,
    required this.utilisateur,
    required this.demarche,
    required this.onClose,
  });

  @override
  State<FormModifDemarche> createState() => _FormModifDemarcheState();
}

class _FormModifDemarcheState extends State<FormModifDemarche> {
  final _formKey = GlobalKey<FormState>();

  final contactModifController = TextEditingController();
  late DateTime dateContact;
  late String statutSelectionne;

  @override
  void initState() {
    super.initState();
    dateContact = DateTime.parse(widget.demarche.dateDemarche);
    statutSelectionne = widget.demarche.statut;
  }

  @override
  void dispose() {
    contactModifController.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mode_edit_rounded, color: Colors.grey),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Modifier une demarche - ${widget.demarche.nomEntreprise}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildDatePicker(),
              EntreeForm(
                txt: 'CONTACT',
                hint: 'Nouvelle coordonnee',
                ctrlr: contactModifController,
                obligatoire: false,
              ),
              _buildStatusSelector(),
              const SizedBox(height: 12),
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
          const Text('DATE', style: TextStyle(color: Colors.grey)),
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

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STATUT', style: TextStyle(color: Colors.grey)),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Cliquer pour modifier',
              style: TextStyle(color: Colors.white70),
            ),
            BoutonStatut(
              onChangementStatut: (value) {
                statutSelectionne = value;
              },
              statutInitial: widget.demarche.statut,
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
        BoutonTexte(
          txt: 'Enregistrer',
          fct: () {
            if (_formKey.currentState!.validate()) {
              var contact = contactModifController.text;
              if (contact.isEmpty) {
                contact = widget.demarche.contact;
              }
              context.read<DemarcheBloc>().add(
                DemarchePutEvent(
                  widget.demarche.siret,
                  dateContact.toString().substring(0, 10),
                  contact,
                  statutSelectionne,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

import 'package:appli_pfmp/data/infos_admin_api.dart';
import 'package:appli_pfmp/bloc/infos_admin_bloc/infos_admin_event.dart';
import 'package:appli_pfmp/bloc/infos_admin_bloc/infos_admin_state.dart';
import 'package:appli_pfmp/model/infos_admin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfosAdminBloc extends Bloc<InfosAdminEvent, InfosAdminState> {
  // Etat par défaut : initialisation de l'état d'affichage des infos admin
  InfosAdminBloc() : super(InfosAdminInitializeState()) {
    // Si l'évènement courant est l'affichage des données administrateur
    on<InfosAdminInitializeEvent>((event, emit) async {
      // Emission de l'état de chargement des informations
      emit(InfosAdminLoadingState());

      // Stockage des informations de l'espace administrateur
      final result = await requestInfosAdmin();

      // Si la requête renvoie des informations
      // ignore: unrelated_type_equality_checks
      if (result != ([], {})) {
        // Stockage des informations (liste des stages et statistiques) dans des variables distinctes
        final List<StagiaireAdmin> stagiairesAdmin = result.stagiairesAdmin;
        final StatsAdmin statsAdmin = result.statsAdmin;

        // Emission de l'état de succès de récupération des informations administrateur
        emit(InfosAdminSuccessState(stagiairesAdmin, statsAdmin));
      } else {
        // Emission de l'état d'échec de récupération des infos admin
        emit(InfosAdminErrorState(Error()));
      }
    });
  }
}

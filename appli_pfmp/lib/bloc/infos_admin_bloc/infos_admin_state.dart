import 'package:appli_pfmp/model/infos_admin.dart';

// Classe d'état parente
class InfosAdminState {
  const InfosAdminState();
}

// Etat initial d'affichage des informations de l'espace administrateur
class InfosAdminInitializeState extends InfosAdminState {
  const InfosAdminInitializeState();
}

// Etat de chargement des données de l'administrateur
class InfosAdminLoadingState extends InfosAdminState {
  const InfosAdminLoadingState();
}

// Etat de succès de récupération des informations de l'espace administrateur (liste des stages et statistiques générales)
class InfosAdminSuccessState extends InfosAdminState {
  final List<StagiaireAdmin> infosStagiairesAdmin;
  final StatsAdmin statsAdmin;
  const InfosAdminSuccessState(this.infosStagiairesAdmin, this.statsAdmin);
}

// Etat d'erreur de récupération des informations de l'admin
class InfosAdminErrorState extends InfosAdminState {
  final Error error;
  const InfosAdminErrorState(this.error);
}

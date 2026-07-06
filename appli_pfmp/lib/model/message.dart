class MessagePfmp {
  final int idUtilisateur;
  final int idPfmp;
  final String roleExpediteur;
  final String contenu;
  final String? dateEnvoi;
  final int idMessage;

  const MessagePfmp({
    required this.idUtilisateur,
    required this.idPfmp,
    required this.roleExpediteur,
    required this.contenu,
    required this.dateEnvoi,
    required this.idMessage,
  });

  factory MessagePfmp.fromJson(Map<String, dynamic> json) => MessagePfmp(
    idUtilisateur: json['idUtilisateur'] ?? json['id_Utilisateur'] ?? 0,
    idPfmp: json['idPfmp'] ?? json['id_PFMP'] ?? 0,
    roleExpediteur: json['roleExpediteur'] ?? '',
    contenu: json['contenu'] ?? '',
    dateEnvoi: json['dateEnvoi'],
    idMessage: json['idMessage'] ?? json['id_Message'] ?? 0,
  );
}

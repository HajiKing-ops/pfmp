import 'package:appli_pfmp/bloc/authentification_bloc/authentification_event.dart';
import 'package:appli_pfmp/bloc/authentification_bloc/authentification_state.dart';
import 'package:appli_pfmp/data/authentification_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthentificationBloc
    extends Bloc<AuthentificationEvent, AuthentificationState> {
  AuthentificationBloc() : super(const AuthentificationInitializeState()) {
    on<AuthentificationLoginEvent>((event, emit) async {
      if (event.nomUser.isEmpty || event.pwd.isEmpty) {
        emit(
          const AuthentificationErrorState(
            'Veuillez saisir un login et un mot de passe',
          ),
        );
        return;
      }

      final loginResult = await loginRequest(event.nomUser, event.pwd);
      final currentUser = loginResult.user;

      if (currentUser != null) {
        emit(AuthentificationSuccessState(currentUser));
        return;
      }

      emit(
        AuthentificationErrorState(
          loginResult.errorMessage ?? 'Connexion impossible',
        ),
      );
    });

    on<AuthentificationLogoutEvent>((event, emit) {
      emit(const AuthentificationInitializeState());
    });
  }
}

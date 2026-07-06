import 'package:appli_pfmp/bloc/authentification_bloc/authentification_bloc.dart';
import 'package:appli_pfmp/bloc/authentification_bloc/authentification_event.dart';
import 'package:appli_pfmp/bloc/authentification_bloc/authentification_state.dart';
import 'package:appli_pfmp/custom/custom_widgets/app_logo.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';

class PageAuth extends StatefulWidget {
  const PageAuth({super.key});

  @override
  State<PageAuth> createState() => _PageAuthState();
}

class _PageAuthState extends State<PageAuth> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool maskText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 48, 0, 131),
      body: BlocConsumer<AuthentificationBloc, AuthentificationState>(
        listener: (context, state) {
          if (state is AuthentificationSuccessState) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    PfmpManager(currentUser: state.currentUser),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthentificationSuccessState) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildLoginContent(
            context,
            error: state is AuthentificationErrorState ? state.error : null,
          );
        },
      ),
    );
  }

  Widget _buildLoginContent(
    BuildContext context, {
    String? error,
  }) {
    final logoHeight = Responsive.isMobile(context) ? 116.0 : 154.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: AppLogo(
                          height: logoHeight,
                          maxWidth: 320,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Connexion',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: const InputDecoration(
                          fillColor: Colors.blueGrey,
                          filled: true,
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          hintText: "Nom d'utilisateur",
                        ),
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une adresse mail';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitLogin(),
                        obscureText: maskText,
                        controller: passwordController,
                        decoration: InputDecoration(
                          fillColor: Colors.blueGrey,
                          filled: true,
                          prefixIcon: const Icon(Icons.password_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                maskText = !maskText;
                              });
                            },
                            icon: Icon(
                              maskText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          hintText: 'Mot de passe',
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 180,
                            maxWidth: 260,
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _submitLogin,
                            icon: const Icon(Icons.send),
                            label: const Text('Se connecter'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthentificationBloc>().add(
        AuthentificationLoginEvent(
          emailController.text,
          passwordController.text,
        ),
      );
    }
  }
}

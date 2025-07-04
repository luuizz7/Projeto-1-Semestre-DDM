import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// checa o login do usuario
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // observa o status do login
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // se estiver logado
        if (snapshot.hasData) {
          // mostra a tela principal
          return const HomeScreen();
        } else {
          // se nao estiver logado
          // mostra a tela de login
          return const LoginScreen();
        }
      },
    );
  }
}

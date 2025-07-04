import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// este widget verifica se o usuario esta logado e direciona para a home (caso nao haja erro)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // O StreamBuilder atualiza automaticamente
    // com base em um fluxo de dados em tempo real.
    return StreamBuilder<User?>(
      // A fonte de dados é o status de login do usuário no Firebase.
      stream: FirebaseAuth.instance.authStateChanges(),
      
      // O builder decide o que mostrar na tela com base na informação mais recente (snapshot).
      builder: (context, snapshot) {
        // Se os dados baterem, significa que o usuário está logado.
        if (snapshot.hasData) {
          // Se logado, mostra a tela principal.
          return const HomeScreen();
        } else {
          // Se não, mostra a tela de login.
          return const LoginScreen();
        }
      },
    );
  }
}
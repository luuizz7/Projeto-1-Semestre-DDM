import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// AuthGate é um "portão de autenticação".
// Ele decide qual tela mostrar com base no status de login do usuário.
class AuthGate extends StatelessWidget {
  // Adicionando o construtor com a chave, que é uma boa prática.
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder é um widget que se reconstrói sempre que recebe novos dados de uma Stream.
    // Aqui, ele "ouve" as mudanças no estado de autenticação do Firebase.
    return StreamBuilder<User?>(
      // FirebaseAuth.instance.authStateChanges() é a stream que notifica
      // sobre login (retorna um objeto User) ou logout (retorna null).
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se há um usuário logado (snapshot.data não é null),
        // mostramos a tela principal do aplicativo.
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          // Se não há usuário logado (snapshot.data é null), mostramos a tela de login.
          return const LoginScreen(); // Usando a versão corrigida do LoginScreen
        }
      },
    );
  }
}
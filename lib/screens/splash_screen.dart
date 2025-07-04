import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_gate.dart'; // nosso verificador de login

// tela de abertura
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // chamado quando a tela eh criada
  @override
  void initState() {
    super.initState();
    
    // espera 3 segundos e vai pra próxima tela
    Timer(const Duration(seconds: 3), () {
      // troca a tela de splash pelo authgate
      // assim o usuário não consegue voltar pra cá
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

  // desenha o que aparece na tela
  @override
  Widget build(BuildContext context) {
    // esqueleto da tela
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // icone do app
            Icon(
              Icons.movie_filter_sharp,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            // titulo do app
            const Text(
              'Meu Catálogo de Filmes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

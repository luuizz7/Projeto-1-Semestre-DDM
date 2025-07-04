import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_gate.dart'; // Importamos o AuthGate, que é nosso próximo passo.

// Esta é a tela de abertura do aplicativo (Splash Screen).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // O método initState é chamado uma única vez, quando a tela é criada.
  // É o lugar perfeito para iniciar tarefas que acontecem em segundo plano.
  @override
  void initState() {
    super.initState();
    
    // Usamos um Timer para esperar um tempo antes de mudar de tela.
    Timer(const Duration(seconds: 3), () {
      // Após 3 segundos, a mágica acontece:
      // O Navigator.pushReplacement troca a tela atual (Splash) pela próxima (AuthGate).
      // 'pushReplacement' impede que o usuário volte para a tela de Splash com o botão "voltar".
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

  // O método build desenha a aparência da nossa tela.
  @override
  Widget build(BuildContext context) {
    // Usamos um Scaffold como esqueleto da tela.
    return Scaffold(
      // Usamos a mesma cor de fundo do nosso tema para ficar bonito.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone temático do nosso aplicativo.
            Icon(
              Icons.movie_filter_sharp,
              size: 100,
              color: Theme.of(context).colorScheme.primary, // Cor amarela do tema.
            ),
            const SizedBox(height: 20),
            // Título do aplicativo.
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
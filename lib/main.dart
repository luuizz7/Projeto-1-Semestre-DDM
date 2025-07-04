import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

// nossa tela de verificação de login
import 'screens/auth_gate.dart';

// função principal do app
void main() async {
  // garante que o flutter iniciou antes de rodar o resto
  WidgetsFlutterBinding.ensureInitialized();
  
  // inicia o firebase com as nossas configurações
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // roda o nosso app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Filmes',
      // tira a faixa de debug (porque se nao tirar ela, fica em cima do nosso botao de sair)
      debugShowCheckedModeBanner: false, 
      // tema escuro com detalhes em amarelo
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber,
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.amber,
          secondary: Colors.blueAccent,
        ),
      ),
      // a tela inicial é o nosso verificador de login
      home: AuthGate(),
    );
  }
}

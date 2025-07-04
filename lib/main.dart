// Importa o pacote principal do Flutter.
import 'package:flutter/material.dart';

// Importa o pacote principal do Firebase.
import 'package:firebase_core/firebase_core.dart';

// Importa as configurações do Firebase que foram geradas automaticamente.
import 'firebase_options.dart'; 

// Importa sua tela de "portão de autenticação".
import 'screens/auth_gate.dart';

// A função 'main' precisa ser 'async' para que possamos usar 'await' nela.
void main() async {
  // Garante que o Flutter esteja totalmente inicializado antes de chamar o Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  
  // ESTE É O CÓDIGO DE INICIALIZAÇÃO NO LUGAR CORRETO
  // Ele usa as opções do arquivo firebase_options.dart.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicia o seu aplicativo.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Filmes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber,
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.amber,
          secondary: Colors.blueAccent,
        ),
      ),
      home: AuthGate(),
    );
  }
}
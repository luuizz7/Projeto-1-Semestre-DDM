import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Função para exibir mensagens de erro (SnackBar) de forma centralizada.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleAuth(Future<UserCredential> Function() authAction) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      await authAction();
      // Se a autenticação for bem-sucedida, o AuthGate cuidará da navegação.
      // Não precisamos fazer nada aqui.
    } on FirebaseAuthException catch (e) {
      // --- MELHORIA: Lógica para traduzir erros ---
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'E-mail ou senha inválida. Verifique seus dados.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Este e-mail já está em uso. Tente fazer login.';
          break;
        case 'weak-password':
          errorMessage = 'A senha é muito fraca. Tente uma mais forte.';
          break;
        case 'invalid-email':
          errorMessage = 'O formato do e-mail é inválido.';
          break;
        default:
          errorMessage = 'Ocorreu um erro. Tente novamente mais tarde.';
      }
      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos a cor de fundo do tema para manter a consistência.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          // MELHORIA: Padding para dar um respiro em volta do formulário.
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // MELHORIA: Limitamos a largura do formulário para que ele não fique
          // esticado em telas grandes como a do seu PC.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MELHORIA: Adicionamos um ícone e um título para dar identidade visual.
                Icon(
                  Icons.movie_filter_sharp,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bem-vindo ao Catálogo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        // MELHORIA: Adicionamos um ícone dentro do campo.
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Por favor, insira um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 4) {
                            return 'A senha deve ter pelo menos 4 caracteres.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // MELHORIA: Botão de "Entrar" com mais destaque.
                      ElevatedButton(
                        onPressed: () => _handleAuth(
                          () => FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 12),
                      // MELHORIA: Botão de "Criar Conta" como um botão de texto,
                      // que é uma ação secundária.
                      TextButton(
                        onPressed: () => _handleAuth(
                          () => FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          ),
                        ),
                        child: const Text('Não tem uma conta? Criar Conta'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Esta é a tela de Login e Cadastro do nosso aplicativo.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave para validar o formulário de e-mail e senha.
  final _formKey = GlobalKey<FormState>();

  // Controladores para pegar o texto que o usuário digita.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variável para controlar a animação de "carregando".
  bool _isLoading = false;

  // --- Função para fazer o LOGIN (ENTRAR) ---
  Future<void> _fazLogin() async {
    // 1. Valida se os campos foram preenchidos corretamente.
    if (!_formKey.currentState!.validate()) {
      return; // Para a execução se o formulário for inválido.
    }

    // 2. Mostra a animação de carregando.
    setState(() { _isLoading = true; });

    // 3. Tenta fazer o login no Firebase.
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Se o login der certo, o AuthGate nos levará para a tela principal.
    } on FirebaseAuthException catch (e) {
      // Se der erro, mostra uma mensagem amigável para o usuário.
      String mensagem = 'Ocorreu um erro.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensagem = 'E-mail ou senha incorreta.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
    }

    // 4. Esconde a animação de carregando.
    setState(() { _isLoading = false; });
  }
  
  // --- Função para CRIAR UMA NOVA CONTA ---
  Future<void> _criaConta() async {
    // 1. Valida o formulário.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Mostra o carregando.
    setState(() { _isLoading = true; });

    // 3. Tenta criar a conta no Firebase.
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Se der certo, o AuthGate já nos joga para a tela principal.
    } on FirebaseAuthException catch (e) {
      // Trata os erros mais comuns de cadastro.
      String mensagem = 'Ocorreu um erro.';
      if (e.code == 'email-already-in-use') {
        mensagem = 'Este e-mail já está cadastrado. Tente fazer login.';
      } else if (e.code == 'weak-password') {
        mensagem = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
    }

    // 4. Esconde o carregando.
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // Caixa para limitar a largura do formulário em telas grandes.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone e título da tela.
                Icon(Icons.movie_filter_sharp, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 20),
                const Text('Bem-vindo ao Catálogo', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                
                // O formulário com os campos de texto.
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return 'Por favor, insira um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                        obscureText: true, // Esconde a senha.
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Se estiver carregando, mostra a animação. Senão, mostra os botões.
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _fazLogin, // Chama a função de login.
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _criaConta, // Chama a função de criar conta.
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
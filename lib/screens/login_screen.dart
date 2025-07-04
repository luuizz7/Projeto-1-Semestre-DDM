import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// tela de login e cadastro
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // chave pro formulário
  final _formKey = GlobalKey<FormState>();

  // controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // pra mostrar o "carregando"
  bool _isLoading = false;

  // função para entrar
  Future<void> _fazLogin() async {
    // valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // mostra o carregando
    setState(() { _isLoading = true; });

    // tenta fazer o login
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // se der certo, o authgate cuida do resto
    } on FirebaseAuthException catch (e) {
      // se der erro, mostra uma mensagem
      String mensagem = 'Ocorreu um erro.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensagem = 'E-mail ou senha incorreta.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
    }

    // esconde o carregando
    setState(() { _isLoading = false; });
  }
  
  // função pra criar conta
  Future<void> _criaConta() async {
    // valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // mostra o carregando
    setState(() { _isLoading = true; });

    // tenta criar a conta
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // se der certo, o authgate cuida do resto
    } on FirebaseAuthException catch (e) {
      // trata os erros mais comuns
      String mensagem = 'Ocorreu um erro.';
      if (e.code == 'email-already-in-use') {
        mensagem = 'Este e-mail já está cadastrado. Tente fazer login.';
      } else if (e.code == 'weak-password') {
        mensagem = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
    }

    // esconde o carregando
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // uma caixa pra limitar a largura em telas grandes
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // icone e titulo
                Icon(Icons.movie_filter_sharp, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 20),
                const Text('Bem-vindo ao Catálogo', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                
                // formulário
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
                        obscureText: true, 
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
                
                // mostra o carregamento
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _fazLogin, // chama a função de login
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _criaConta, // chama a função de criar conta
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
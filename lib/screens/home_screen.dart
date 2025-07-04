import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';

// Esta é a tela principal do app, que o usuário vê após o login.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Função simples para pegar o ID do usuário que está logado.
  String _getUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }
  
  // Função que abre a "janelinha" (AlertDialog) para o usuário adicionar um novo filme.
  void _abrirDialogoAdicionarFilme() {
    // Controladores que guardam o texto que o usuário digita nos campos.
    final titleController = TextEditingController();
    final posterUrlController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Filme'),
          // Conteúdo da janela com os campos de texto.
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
                TextField(controller: posterUrlController, decoration: const InputDecoration(labelText: 'URL da Imagem do Pôster')),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descrição')),
              ],
            ),
          ),
          // Botões de ação da janela.
          actions: [
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  // Adiciona o novo filme na lista do usuário no Firestore.
                  FirebaseFirestore.instance
                    .collection('users')
                    .doc(_getUserId())
                    .collection('movies')
                    .add({
                      'title': titleController.text,
                      'posterUrl': posterUrlController.text,
                      'description': descriptionController.text,
                      'createdAt': Timestamp.now(), // Guarda a data para ordenar.
                    });
                  Navigator.of(context).pop(); // Fecha a janela após salvar.
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Catálogo de Filmes'),
        actions: [
          // Botão para fazer logout (sair).
          IconButton(
            icon: const Icon(Icons.logout), 
            tooltip: 'Sair', 
            onPressed: () => FirebaseAuth.instance.signOut()
          ),
        ],
      ),
      // O corpo da tela usa um StreamBuilder para "ouvir" as mudanças
      // na lista de filmes do Firebase em tempo real.
      body: StreamBuilder<QuerySnapshot>(
        // O caminho que ele "ouve": a coleção de filmes do usuário logado.
        stream: FirebaseFirestore.instance.collection('users').doc(_getUserId()).collection('movies').orderBy('createdAt', descending: true).snapshots(),
        
        builder: (context, snapshot) {
          // Se estiver carregando, mostra uma animação de progresso.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se a lista estiver vazia, mostra uma mensagem amigável.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Sua lista está vazia.\nClique no + para adicionar um filme.', textAlign: TextAlign.center));
          }

          // Pega a lista de filmes que o Firebase enviou.
          final filmes = snapshot.data!.docs;

          // Usa o GridView.builder para desenhar a grade de filmes.
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            // Configuração da grade: itens com no máximo 200px de largura.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: filmes.length,
            // 'itemBuilder' desenha um card para cada filme na lista.
            itemBuilder: (context, index) {
              final filme = filmes[index];
              final posterUrl = filme['posterUrl'] as String? ?? '';

              // GestureDetector detecta o clique em cada card.
              return GestureDetector(
                onTap: () {
                  // Navega para a tela de detalhes quando um filme é clicado.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        userId: _getUserId(),
                        movieId: filme.id, // Envia o ID do filme para a próxima tela.
                      ),
                    ),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Espaço para a imagem do pôster.
                      Expanded(
                        child: posterUrl.isNotEmpty
                          ? Image.network(posterUrl, fit: BoxFit.cover)
                          : const Icon(Icons.movie, size: 80, color: Colors.grey),
                      ),
                      // Espaço para o título do filme.
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(filme['title'], textAlign: TextAlign.center, maxLines: 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Botão flutuante para chamar a janela de adicionar filme.
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogoAdicionarFilme,
        tooltip: 'Adicionar Filme',
        child: const Icon(Icons.add),
      ),
    );
  }
}
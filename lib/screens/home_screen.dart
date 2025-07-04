import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  void _abrirDialogoAdicionarFilme() {
    // Controladores para os campos de texto.
    final titleController = TextEditingController();
    final posterUrlController = TextEditingController();
    final descriptionController = TextEditingController();
    // --- ADICIONADO DE VOLTA ---
    final directorController = TextEditingController();
    final yearController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Filme'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
                // --- ADICIONADO DE VOLTA ---
                TextField(controller: directorController, decoration: const InputDecoration(labelText: 'Diretor')),
                TextField(controller: yearController, decoration: const InputDecoration(labelText: 'Ano'), keyboardType: TextInputType.number),
                // --- FIM DA ADIÇÃO ---
                TextField(controller: posterUrlController, decoration: const InputDecoration(labelText: 'URL da Imagem do Pôster')),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descrição')),
              ],
            ),
          ),
          actions: [
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  FirebaseFirestore.instance
                    .collection('users')
                    .doc(_getUserId())
                    .collection('movies')
                    .add({
                      'title': titleController.text,
                      'posterUrl': posterUrlController.text,
                      'description': descriptionController.text,
                      // --- ADICIONADO DE VOLTA ---
                      'director': directorController.text,
                      'year': int.tryParse(yearController.text) ?? 0, // Converte para número
                      // --- FIM DA ADIÇÃO ---
                      'createdAt': Timestamp.now(),
                    });
                  Navigator.of(context).pop();
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
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => FirebaseAuth.instance.signOut()
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_getUserId()).collection('movies').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Sua lista está vazia.\nClique no + para adicionar um filme.', textAlign: TextAlign.center));
          }

          final filmes = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: filmes.length,
            itemBuilder: (context, index) {
              final filme = filmes[index];
              final posterUrl = filme['posterUrl'] as String? ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        userId: _getUserId(),
                        movieId: filme.id,
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
                      Expanded(
                        child: posterUrl.isNotEmpty
                          ? Image.network(posterUrl, fit: BoxFit.cover)
                          : const Icon(Icons.movie, size: 80, color: Colors.grey),
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogoAdicionarFilme,
        tooltip: 'Adicionar Filme',
        child: const Icon(Icons.add),
      ),
    );
  }
}
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
  // Pega o ID do usuário logado para saber de quem é a lista de filmes.
  String getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuário não está logado!");
    }
    return user.uid;
  }

  // --- LÓGICA PARA ADICIONAR UM NOVO FILME ---
  Future<void> _showAddMovieDialog() async {
    // Controladores para os campos de texto do formulário.
    final titleController = TextEditingController();
    final directorController = TextEditingController();
    final yearController = TextEditingController();
    final posterUrlController = TextEditingController();
    final descriptionController = TextEditingController();

    // Chave para validar o formulário.
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Filme'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: directorController,
                    decoration: const InputDecoration(labelText: 'Diretor'),
                  ),
                  TextFormField(
                    controller: yearController,
                    decoration: const InputDecoration(labelText: 'Ano de Lançamento'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: posterUrlController,
                    decoration: const InputDecoration(labelText: 'URL da Imagem do Pôster'),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                // Valida o formulário antes de salvar.
                if (formKey.currentState!.validate()) {
                  // Salva o filme na subcoleção do usuário.
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(getUserId())
                      .collection('movies')
                      .add({
                    'title': titleController.text,
                    'director': directorController.text,
                    'year': int.tryParse(yearController.text) ?? 0,
                    'posterUrl': posterUrlController.text,
                    'description': descriptionController.text,
                    'createdAt': Timestamp.now(), // Para ordenar no futuro
                  });
                  Navigator.of(context).pop(); // Fecha o diálogo
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
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      // --- O StreamBuilder AGORA LÊ A SUBCOLEÇÃO DO USUÁRIO ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(getUserId())
            .collection('movies')
            .orderBy('createdAt', descending: true) // Ordena pelos mais recentes
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Mensagem que aparece quando o usuário ainda não adicionou nenhum filme.
            return const Center(
              child: Text(
                'Sua lista está vazia.\nClique no botão + para adicionar um filme.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final movies = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.7,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final posterUrl = movie['posterUrl'] ?? '';

              return GestureDetector(
                onTap: () {
                  // AVISO: A tela de detalhes precisará de ajustes para funcionar com esta nova estrutura.
                  // Podemos fazer isso no próximo passo.
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => MovieDetailScreen(movieId: movie.id, userId: getUserId()),
                  //   ),
                  // );
                },
                child: Card(
                  elevation: 5,
                  clipBehavior: Clip.antiAlias, // Para cortar a imagem na borda do card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: posterUrl.isNotEmpty
                            ? Image.network(
                                posterUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.movie, size: 100, color: Colors.grey),
                              )
                            : const Icon(Icons.movie, size: 100, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          movie['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // --- BOTÃO FLUTUANTE PARA ADICIONAR FILMES ---
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMovieDialog,
        tooltip: 'Adicionar Filme',
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Esta tela mostra as informações de um filme específico que o usuário selecionou.
class DetailScreen extends StatelessWidget {
  // A tela precisa saber o ID do usuário e o ID do filme para buscar os dados certos.
  final String userId;
  final String movieId;

  // Construtor que recebe os IDs da tela anterior.
  const DetailScreen({
    super.key,
    required this.userId,
    required this.movieId,
  });

  // Função que mostra a janela de confirmação antes de deletar o filme.
  void _abrirDialogoDeletar(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que quer deletar este filme?'),
          actions: [
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Deletar'),
              onPressed: () {
                // deleta o filme do banco de dados
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('movies')
                    .doc(movieId)
                    .delete();
                
                // Fecha o diálogo e a tela de detalhes, voltando para a lista
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos um FutureBuilder para tarefas que demoram um pouco e acontecem só uma vez,
    // como buscar os dados de um filme específico no Firebase.
    return FutureBuilder<DocumentSnapshot>(
      // A "tarefa futura" que ele vai executar: buscar o documento do filme.
      future: FirebaseFirestore.instance.collection('users').doc(userId).collection('movies').doc(movieId).get(),
      
      // O builder desenha a tela com base no resultado da tarefa.
      builder: (context, snapshot) {
        
        // 1. Enquanto a busca está acontecendo, mostramos uma tela de carregamento.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }

        // 2. Se deu algum erro ou o filme não foi encontrado, mostramos um aviso.
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Filme não encontrado.')));
        }

        // 3. Se a busca deu certo, pegamos os dados do filme.
        final dadosDoFilme = snapshot.data!.data() as Map<String, dynamic>;
        final posterUrl = dadosDoFilme['posterUrl'] as String? ?? '';
        final director = dadosDoFilme['director'] as String? ?? 'N/A';
        final year = dadosDoFilme['year'] ?? 'N/A';

        // E finalmente, construímos a tela com os dados encontrados.
        return Scaffold(
          appBar: AppBar(
            title: Text(dadosDoFilme['title'] ?? 'Detalhes'),
            // Adiciona o botão de lixeira na barra de título.
            actions: [
              IconButton(icon: const Icon(Icons.delete), tooltip: 'Deletar Filme', onPressed: () => _abrirDialogoDeletar(context)),
            ],
          ),
          // Usamos um SingleChildScrollView para que a tela possa ser rolada
          // caso a descrição do filme seja muito longa.
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostra o pôster do filme no topo.
                if (posterUrl.isNotEmpty)
                  Image.network(
                    posterUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                
                // Um Padding para dar um respiro ao redor das informações de texto.
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título do filme.
                      Text(
                        dadosDoFilme['title'] ?? 'Título não disponível',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Diretor e Ano.
                      Text(
                        'Diretor: $director • Ano: $year',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Divider(height: 32),
                      // Descrição do filme.
                      Text(
                        'Descrição',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dadosDoFilme['description'] ?? 'Nenhuma descrição fornecida.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
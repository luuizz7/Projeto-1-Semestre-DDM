import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// tela de detalhes do filme
class DetailScreen extends StatelessWidget {
  // id do usuario e do filme
  final String userId;
  final String movieId;

  // construtor
  const DetailScreen({
    super.key,
    required this.userId,
    required this.movieId,
  });

  // abre dialogo para deletar
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
                // deleta o filme
                FirebaseFirestore.instance.collection('users').doc(userId).collection('movies').doc(movieId).delete();
                // volta pra tela inicial
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
    // busca os dados do filme no firebase
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).collection('movies').doc(movieId).get(),
      // constroi a tela com base no resultado
      builder: (context, snapshot) {
        // enquanto carrega, mostra um circulo
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }

        // se der erro ou nao achar o filme
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Filme não encontrado.')));
        }

        // se deu certo, pega os dados
        final dadosDoFilme = snapshot.data!.data() as Map<String, dynamic>;
        final posterUrl = dadosDoFilme['posterUrl'] as String? ?? '';
        final director = dadosDoFilme['director'] as String? ?? 'N/A';
        final year = dadosDoFilme['year'] ?? 'N/A';

        // constroi a tela com os dados
        return Scaffold(
          appBar: AppBar(
            title: Text(dadosDoFilme['title'] ?? 'Detalhes'),
            // botao de lixeira
            actions: [
              IconButton(icon: const Icon(Icons.delete), tooltip: 'Deletar Filme', onPressed: () => _abrirDialogoDeletar(context)),
            ],
          ),
          // permite rolar a tela
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // poster do filme
                if (posterUrl.isNotEmpty)
                  Image.network(
                    posterUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                
                // espacamento
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // titulo
                      Text(
                        dadosDoFilme['title'] ?? 'Título não disponível',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // diretor e ano
                      Text(
                        'Diretor: $director • Ano: $year',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Divider(height: 32),
                      // descricao
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

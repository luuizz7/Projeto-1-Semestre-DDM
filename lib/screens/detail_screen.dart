import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieDetailScreen extends StatefulWidget {
  // Recebe o ID do filme da tela anterior.
  final String movieId;
  
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  double _userRating = 0; // Armazena a avaliação que o usuário está dando.
  bool _isRated = false; // Controla se o usuário já avaliou este filme.

  // Pega o ID do usuário atual para registrar a avaliação em nome dele.
  String getUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }
  
  @override
  void initState() {
    super.initState();
    _fetchUserRating();
  }

  // Busca a avaliação que este usuário já deu para este filme, se houver.
  void _fetchUserRating() async {
    final userRatingDoc = await FirebaseFirestore.instance
      .collection('movies').doc(widget.movieId)
      .collection('ratings').doc(getUserId()).get();
    
    if (userRatingDoc.exists) {
      setState(() {
        _userRating = (userRatingDoc['rating'] as num).toDouble();
        _isRated = true;
      });
    }
  }

  // Função para salvar ou atualizar a avaliação do usuário.
  void _submitRating() {
    if (_userRating > 0) {
      // Acessa a subcoleção 'ratings' dentro do documento do filme.
      // Usa o ID do usuário como ID do documento da avaliação.
      // Isso garante que cada usuário só pode ter uma avaliação por filme.
      FirebaseFirestore.instance
          .collection('movies')
          .doc(widget.movieId)
          .collection('ratings')
          .doc(getUserId())
          .set({ // 'set' cria o documento se não existir, ou atualiza se já existir.
            'rating': _userRating,
            'userId': getUserId(),
          });
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avaliação enviada com sucesso!')),
      );
      setState(() {
        _isRated = true;
      });
    }
  }
  
  // Widget para construir as estrelas de avaliação.
  Widget _buildRatingStars(double averageRating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      IconData icon = Icons.star_border;
      if (i <= averageRating) {
        icon = Icons.star;
      } else if (i - 0.5 <= averageRating) {
        icon = Icons.star_half;
      }
      stars.add(Icon(icon, color: Colors.amber));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Filme")),
      // FutureBuilder é ideal para carregar dados que não mudam em tempo real (one-time fetch).
      // Aqui, ele busca os detalhes do filme uma única vez quando a tela abre.
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('movies').doc(widget.movieId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Filme não encontrado.'));
          }

          // Pega os dados do filme.
          final movieData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 300,
                    child: Image.network(movieData['posterUrl'] ?? '', errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.movie, size: 100, color: Colors.grey);
                          },),
                  ),
                ),
                SizedBox(height: 20),
                Text(movieData['title'] ?? 'Sem título', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 8),
                Text('Diretor: ${movieData['director'] ?? 'N/A'} - Ano: ${movieData['year'] ?? 'N/A'}'),
                SizedBox(height: 16),
                Text(movieData['description'] ?? 'Sem descrição.', style: Theme.of(context).textTheme.bodyMedium),
                Divider(height: 40),
                
                // --- Seção de Avaliação Média (StreamBuilder aninhado) ---
                Text('Avaliação da Comunidade', style: Theme.of(context).textTheme.titleLarge),
                // Este StreamBuilder observa as avaliações em tempo real.
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('movies').doc(widget.movieId).collection('ratings').snapshots(),
                  builder: (context, ratingSnapshot) {
                    if (!ratingSnapshot.hasData || ratingSnapshot.data!.docs.isEmpty) {
                      return Text('Ainda não há avaliações.');
                    }
                    // Calcula a média das avaliações.
                    double total = 0;
                    for (var doc in ratingSnapshot.data!.docs) {
                      total += doc['rating'];
                    }
                    double average = total / ratingSnapshot.data!.docs.length;
                    return Row(
                      children: [
                        _buildRatingStars(average),
                        SizedBox(width: 8),
                        Text('${average.toStringAsFixed(1)} / 5.0'),
                      ],
                    );
                  }
                ),
                
                Divider(height: 40),

                // --- Seção para o Usuário Avaliar ---
                Text('Sua Avaliação', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 10),
                // Slider para o usuário escolher a nota de 1 a 5.
                Slider(
                  value: _userRating,
                  onChanged: (newRating) {
                    setState(() {
                      _userRating = newRating;
                    });
                  },
                  min: 0,
                  max: 5,
                  divisions: 10, // Permite meias-estrelas (0.5, 1.0, 1.5...)
                  label: _userRating.toStringAsFixed(1),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitRating,
                    child: Text(_isRated ? 'Atualizar Avaliação' : 'Enviar Avaliação'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
# Meu Catálogo de Filmes 🎬

Bem-vindo ao **Meu Catálogo de Filmes**! Este é um aplicativo simples e elegante, construído com Flutter e Firebase, que permite criar e gerenciar sua própria coleção de filmes. Com ele, você pode salvar os filmes que já assistiu, os que deseja ver e ter tudo organizado em um só lugar.


#### 👨‍🏫 Professora responsável
Ana Paula Abrantes de Castro Shiguemori

## ✨ Funcionalidades Principais

* **Autenticação Segura**: Crie sua conta ou faça login de forma rápida e segura com e-mail e senha. Seus dados são protegidos pelo Firebase Authentication.
* **Adicione Filmes Facilmente**: Com um clique no botão `+`, um formulário intuitivo permite que você cadastre novos filmes, adicionando informações como título, diretor, ano de lançamento, uma breve descrição e até a URL de um pôster.
* **Galeria Personalizada**: Seus filmes são exibidos em uma grade visualmente agradável na tela inicial, mostrando o pôster e o título de cada um.
* **Veja os Detalhes**: Ao clicar em um filme, você acessa uma tela com todas as informações detalhadas: pôster em destaque, sinopse, diretor e ano.
* **Exclua o que não quer mais**: Não gostou de um filme ou adicionou por engano? É só abrir os detalhes e usar o ícone da lixeira para removê-lo da sua coleção.
* **Design Moderno e Responsivo**: O app conta com um tema escuro e se adapta bem a diferentes tamanhos de tela.

## 🚀 Como o Projeto Funciona?

O aplicativo foi estruturado de forma modular para facilitar o entendimento e a manutenção. Abaixo está uma visão geral de como tudo se conecta:

### Estrutura dos Arquivos
* `main.dart`: O ponto de partida do aplicativo. É aqui que o Firebase é inicializado e o tema geral do app é configurado.
* `splash_screen.dart`: Uma tela de abertura amigável que aparece por 3 segundos para dar as boas-vindas ao usuário antes de verificar se ele está logado.
* `auth_gate.dart`: Atua como um "porteiro". Ele verifica o status de autenticação do usuário em tempo real e decide se deve mostrar a tela de login ou a tela principal com a lista de filmes.
* `login_screen.dart`: A porta de entrada para novos e antigos usuários. Oferece os formulários para criar uma nova conta ou para fazer login com uma conta existente.
* `home_screen.dart`: O coração do aplicativo! Exibe a coleção de filmes do usuário em uma grade e possui o botão flutuante para adicionar novos títulos. A tela se atualiza em tempo real sempre que um novo filme é adicionado.
* `detail_screen.dart`: Mostra todas as informações de um filme selecionado e oferece a opção de exclusão.
* `firebase_options.dart`: Arquivo gerado pelo FlutterFire que contém todas as chaves e configurações necessárias para conectar o app ao seu projeto Firebase.

## 🛠️ Tecnologias Utilizadas

* **Flutter**: Para construir a interface de usuário bonita e nativa para múltiplas plataformas.
* **Firebase**:
    * **Firebase Authentication**: Para gerenciar o login e cadastro de usuários.
    * **Cloud Firestore**: Como banco de dados NoSQL para armazenar a coleção de filmes de cada usuário de forma segura e organizada.

## ⚠️ Limitações Conhecidas

* O aplicativo não possui um modo offline; é necessária uma conexão com a internet para carregar, adicionar ou remover filmes.
* As informações dos filmes, como pôster e descrição, devem ser inseridas manually pelo usuário.

Este projeto foi desenvolvido com carinho para ser um exemplo prático e funcional de como integrar Flutter e Firebase.

#### 💻 Desenvolvedores
Luiz Henrique da Silva Pereira e Luis Gustavo Novaes dos Santos

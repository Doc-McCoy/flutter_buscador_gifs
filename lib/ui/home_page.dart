import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:convert';
import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search; // Palavra que o usuário irá buscar
  int _offset = 0; // Variável de controle de paginação do resultado.

  /* Função que pega os GIFs na API. */
  Future<Map> _getGifs() async {

    http.Response response;

    /* Caso não seja feita nenhuma busca, exibir os GIFs do Trending */
    if (_search == null || _search.isEmpty) {
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=x5eU5ndT5ogimQA0Uhmr19sxnKEMY4u8&limit=20&rating=G");

    } else {
      /* Caso contrário, fazer a busca da palavra digitada no offset indicado: */
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=x5eU5ndT5ogimQA0Uhmr19sxnKEMY4u8&q=$_search&limit=19&offset=$_offset&rating=G&lang=pt");
    }

    return json.decode(response.body);
  }

  /* Teste feito inicialmente, onde o initState era sobrescrito para printar
   * a resposta da API assim que o mesmo inicializasse. */
  /* @override
  void initState() {

    super.initState();

    _getGifs().then((map) {
      print(map);
    });
  } */

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.black,
        // O título em si é o endereço de um GIF:
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),

      backgroundColor: Colors.black,

      body: Column(
        children: <Widget>[

          Padding(

            padding: EdgeInsets.all(10.0),
            
            // Campo de busca
            child: TextField(

              decoration: InputDecoration(
                labelText: "Pesquise Aqui!",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder()
              ),

              style: TextStyle(color: Colors.white, fontSize: 18.0),
              
              textAlign: TextAlign.center,

              /* Função onSubmitted é chamada ao pressionao o "ok" no teclado
               *do Android. Ela requer uma função que recebe o texto digitado.
               */
              onSubmitted: (texto) {
                // Chamando o setState eu garanto que a tela irá recarregar.
                setState(() {
                  _search = texto;
                  _offset = 0; // Zerei o offset, pois uma nova busca foi feita.
                });
              },

            ),
          ),
          
          Expanded(

            child: FutureBuilder(

              // Indicar a função que retorna os dados deste widget.
              future: _getGifs(),

              // O builder sempre necessita de um context e o snapshot que é que o future retorna.
              builder: (context, snapshot) {
                // Tratar o que exibir enquanto carrega, e depois que carrega (default).
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    // Container com uma animação de "loading" apenas:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );

                  default: // Quando carregar os dados:
                    // O caso de erro não foi tratado aqui.
                    if (snapshot.hasError) return Container();
                    // Caso tenha sucesso, chamar a funcao _createGifTable:
                    else return _createGifTable(context, snapshot);
                }
              },
            ),

          ),
        ],
      ),
    );
  }

  /* Função que retorna a quantidade de itens a exibir no resultado.
   * Ela foi necessária pois quando é feito uma pesquisa, o último item
   * será o ícone de 'pesquisar mais'.
   */
  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  /* Widget que cria cada quadradinho de GIF resultado da pesquisa: */
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {

    return GridView.builder(

      padding: EdgeInsets.all(10.0),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de colunas do Grid
        crossAxisSpacing: 10.0, // Espaçamento dos itens do Grid
        mainAxisSpacing: 10.0, // Espaçamento entre os itens do Grid
      ),

      // Quantidade de itens do Grid
      itemCount: _getCount(snapshot.data["data"]),

      // Função chamada para construir cada item do Grid
      itemBuilder: (context, index) {

        // Caso o item atual não seja o último:
        if (_search == null || index < snapshot.data["data"].length) {

          // Widget que detecta gestos no seu Child:
          return GestureDetector(

            // Widget FadeInImage faz o efeito de carregar os GIFs suavemente:
            child: FadeInImage.memoryNetwork(
              /* Placeholder é a imagem inicial, no caso, a transparência que
               *importamos com o plugin transparent_image.
               */
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),

            // Ação de clicar no widget:
            onTap: () {
              /* IMPORTANTE! Essa parte é onde a tela fig_page.dart é carregada,
               * juntamente com o parâmetro necessário especificado no construtor
               * do GifPage().
               * Repare que na função anônima, o => significa 'return'.
               */
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
              );
            },

            // Ação de pressionar e segurar o widget:
            onLongPress: () {
              // Aparecer as opções de compartilhamento (isso vem do plugin 'share'):
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );

        // Caso seja o último, buildar um grid com a opção de "Carregar mais":
        } else {

          return Container(

            child: GestureDetector(

              // O widget de 'carregar mais' é um column com um icone e um texto:
              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0,),
                  Text("Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  ),
                ],

              ),

              // Ao pressionar, mudar o offset para ver os próximos 19 GIFs:
              onTap: () {
                // Repare que por ter um setState, tudo é rebuildado ao clicar:
                setState(() {
                  _offset += 19;
                });
              },

            ),

          );

        }

      },
    );
  }
}

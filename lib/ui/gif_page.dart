import 'package:flutter/material.dart';
import 'package:share/share.dart';

/* Essa tela se trata de um statelessWidget, pois serve somente para
 * exibir o GIF selecionado na tela anterior. Não tem ação nenhuma.
 */
class GifPage extends StatelessWidget {

  final Map _gifData;

  // Construtor da classe, que receberá os dados:
  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(_gifData["title"]),
        backgroundColor: Colors.black,

        actions: <Widget>[

          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(_gifData["images"]["fixed_height"]["url"]);
            },
          ),
        ],
      ),

      backgroundColor: Colors.black,

      body: Center(
        child: Image.network(_gifData["images"]["fixed_height"]["url"]),
      ),
    );
  }
}

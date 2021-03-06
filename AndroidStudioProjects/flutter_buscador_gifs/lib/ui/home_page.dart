import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import "package:transparent_image/transparent_image.dart";
import 'gif_page.dart';

class HomePage extends StatefulWidget { // páginas dinâmicas -> stateful
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;

  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=gSd2L8sUmVQ3R6ZwLWW5PTOZopcFMJ7G&limit=20&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=gSd2L8sUmVQ3R6ZwLWW5PTOZopcFMJ7G&q=$_search&limit=19&offset=$_offset&rating=g&lang=en");

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){ // O onSubmited serve para o botão de v (enviar) do teclado
                setState(() { // vai pedir para o FutureBuilder reconstruir, o FB vai pegar o futuro
                  _search = text;
                  _offset = 0; //resetar o offset senão ele não vai mostrar os primeiros itens
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGifTable(context, snapshot);
                  }
                }),
          ),
        ],
      ),
    );
  }

  int _getCount(List data){
    if (_search == null){
      return data.length;
    }
    else{
      return data.length+1;
    }
  }
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if(_search == null || index < snapshot.data["data"].length){
            return GestureDetector(
              //serve para poder clicar na imagem e mostrar em uma outra página
              child: FadeInImage.memoryNetwork( // não deixa a imagem aparecer muito rápido, melhorando o estilo da aplicação
                  placeholder: kTransparentImage, //imagem transparente através do plugin "transparent_image"
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  height: 300.0,
                  fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context, // para ir para outra tela
                MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]) ) // cria a rota
                );
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]); //quando tocar na imagem, dar a opção de compartilhar
              },
            );
          }
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0),
                    Text("Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),)
                  ],
                ),
                onTap: (){
                  setState(() {
                    _offset += 19;
                  });
                }
              ),
            );

        });
  }
}

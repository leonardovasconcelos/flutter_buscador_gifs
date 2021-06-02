import 'package:flutter/material.dart';

class GifPage extends StatelessWidget { // páginas estáticas -> stateless
  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) { // conteúdo da página
    return Scaffold(
      appBar: AppBar(
        title: Text(_gifData["title"]), // Título da App Bar
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
      child: Image.network(_gifData["images"]["fixed_height"]["url"]), // Imagem no Centro
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String> createCarro(
    String modelo, String marca, String foto, int ano, double preco) async {
  final response = await http.post(
    Uri.parse('http://localhost:3001/carros'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'modelo': modelo,
      'marca_id': marca,
      'foto': foto,
      'ano': ano,
      'preco': preco,
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    // return Carro.fromJson(jsonDecode(response.body));
    return "Ok! Veículo Inserido com Sucesso";
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

class InclusaoRoute extends StatefulWidget {
  const InclusaoRoute({Key? key}) : super(key: key);

  @override
  _InclusaoRouteState createState() => _InclusaoRouteState();
}

class _InclusaoRouteState extends State<InclusaoRoute> {
  final _edModelo = TextEditingController();
  final _edMarca = TextEditingController();
  final _edPreco = TextEditingController();
  final _edAno = TextEditingController();
  final _edFoto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inclusão de Veículos'),
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        tooltip: 'Voltar',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Container _body() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _edModelo,
            keyboardType: TextInputType.name,
            style: const TextStyle(
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              labelText: "Modelo",
            ),
          ),
          TextFormField(
            controller: _edMarca,
            keyboardType: TextInputType.name,
            style: const TextStyle(
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              labelText: "Marca",
            ),
          ),
          TextFormField(
            controller: _edAno,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              labelText: "Ano",
            ),
          ),
          TextFormField(
            controller: _edPreco,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              labelText: "Preço R\$",
            ),
          ),
          TextFormField(
            controller: _edFoto,
            keyboardType: TextInputType.url,
            style: const TextStyle(
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              labelText: "URL da Foto",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: _gravaDados,
              child: const Text("Incluir",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gravaDados() async {
    if (_edModelo.text == "" ||
        _edMarca.text == "" ||
        _edPreco.text == "" ||
        _edAno.text == "" ||
        _edFoto.text == "") {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Atenção'),
              content: const Text('Por favor, preencha todos os campos'),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok')),
              ],
            );
          });
      return;
    }

    String novo = await createCarro(
      _edModelo.text,
      _edMarca.text,
      _edFoto.text,
      int.parse(_edAno.text),
      double.parse(_edPreco.text),
    );

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Cadastrado Concluído!'),
            content: Text(novo),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok')),
            ],
          );
        });

    _edModelo.text = "";
    _edMarca.text = "";
    _edPreco.text = "";
    _edAno.text = "";
    _edFoto.text = "";
  }
}

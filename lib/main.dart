import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:revenda/carro.dart';
import 'package:revenda/inclusao_route.dart';

// A function that converts a response body into a List<Carro>.
List<Carro> parseCarros(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Carro>((json) => Carro.fromJson(json)).toList();
}

Future<List<Carro>> obterCarros(http.Client client) async {
  final response = await client.get(Uri.parse('http://localhost:3001/carros'));

  // Use the compute function to run parseCarros in a separate isolate.
  return compute(parseCarros, response.body);
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Revenda Herbie';

    return const MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FutureOr atualizaState(dynamic value) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Carro>>(
        future: obterCarros(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return CarrosList3(carros: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InclusaoRoute()),
          ).then(atualizaState);
        },
        tooltip: 'Adicionar Carro',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CarrosList2 extends StatelessWidget {
  const CarrosList2({Key? key, required this.carros}) : super(key: key);

  final List<Carro> carros;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: carros.length,
      itemBuilder: (BuildContext context, int index) {
        Carro carro = carros[index];
        return appBodyImage(carro.foto, carro.modelo, carro.preco);
      },
    );
  }

  Stack appBodyImage(String foto, String modelo, double preco) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 4,
          ),
          child: Image.network(
            foto,
            fit: BoxFit.contain,
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Modelo: $modelo\nPreço: ${NumberFormat.simpleCurrency(locale: "pt_BR").format(preco)}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CarrosList3 extends StatefulWidget {
  //const CarrosList3({Key? key, required this.carros}) : super(key: key);
  CarrosList3({Key? key, required this.carros}) : super(key: key);

//  final List<Carro> carros;
  List<Carro> carros;

  @override
  State<CarrosList3> createState() => _CarrosList3State();
}

class _CarrosList3State extends State<CarrosList3> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.carros.length,
      itemBuilder: (BuildContext context, int index) {
        Carro carro = widget.carros[index];
        return appBodyImage(context, carro.id, carro.foto, carro.modelo, carro.marca,
            carro.ano, carro.preco);
      },
    );
  }

  ListTile appBodyImage(BuildContext context, int id, String foto, String modelo,
      String marca, int ano, double preco) {
    return (ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          foto,
        ),
      ),
      title: Text(marca + " " + modelo),
      subtitle: Text("Ano: " +
          ano.toString() +
          "\n" +
          NumberFormat.simpleCurrency(locale: "pt_BR").format(preco)),
      isThreeLine: true,
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Exclusão'),
              content: Text('Confirma a exclusão do veículo $modelo?'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    deleteCarro(id.toString());
                    setState(() {
                      widget.carros = widget.carros.where((carro) => carro.id != id).toList();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Sim'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Não'),
                ),
              ],
            );
          },
        );
      },
    ));
  }

  Future<http.Response> deleteCarro(String id) async {
    final http.Response response = await http.delete(
      Uri.parse('http://localhost:3001/carros/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }
}

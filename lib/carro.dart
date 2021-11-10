class Carro {
  final int id;
  final String modelo;
  final String marca;
  final int ano;
  final double preco;
  final String foto;

  Carro({
    required this.id,
    required this.modelo,
    required this.marca,
    required this.ano,
    required this.preco,
    required this.foto,
  });

  factory Carro.fromJson(Map<String, dynamic> json) {
    return Carro(
        id: json['id'],
        modelo: json['modelo'],
        marca: json['marca'],
        ano: json['ano'],
        preco: double.parse(json['preco']),
        foto: json['foto']);
  }
}

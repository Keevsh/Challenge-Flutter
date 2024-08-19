import 'package:dio/dio.dart';


Future<List<Map<String, dynamic>>> fetchSearchResults(String query) async {
  try {
    final dio = Dio();
    final response = await dio.get(
      'https://api.mercadolibre.com/sites/MLB/search',
      queryParameters: {'q': query},
    );

    if (response.statusCode == 200) {
      List<dynamic> results = response.data['results'];
      return results.map((item) => {
        'title': item['title'],
        'price': item['price'],
        'image': item['thumbnail'],
        'id': item['id'],
      }).toList();
    } else {
      throw Exception('Error al buscar productos');
    }
  } catch (e) {
    print('Exception: $e');
    throw Exception('Error al buscar productos');
  }
}



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Servicios/API-MercadoLibre.dart';
import 'ProductDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Challenge Flutter',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _searchResults;
  List<Map<String, dynamic>> recentProducts = [];


  @override
  void initState() {
    super.initState();
    _loadRecentProducts();
  }
  Future<void> _loadRecentProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final recentProductsString = prefs.getString('recent_products');

    if (recentProductsString != null) {
      try {
        final List<dynamic> decodedList = json.decode(recentProductsString);
        setState(() {
          recentProducts = List<Map<String, dynamic>>.from(
            decodedList.map((item) => Map<String, dynamic>.from(item)),
          );
        });
        print("Productos recientes cargados: $recentProducts"); // Debug
      } catch (e) {
        print("Error al decodificar productos recientes: $e"); // Debug
      }
    } else {
      print("No hay productos recientes guardados."); // Debug
    }
  }

  Future<void> _saveRecentProducts() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final recentProductsString = json.encode(recentProducts);
      await prefs.setString('recent_products', recentProductsString);
      print("Productos recientes guardados: $recentProducts"); // Debug
    } catch (e) {
      print("Error al guardar productos recientes: $e"); // Debug
    }
  }

  void _addToRecentProducts(Map<String, dynamic> product) {
    setState(() {
      recentProducts.removeWhere((item) => item['id'] == product['id']);
      recentProducts.insert(0, product);

      if (recentProducts.length > 5){
        recentProducts.removeAt(5);
      }
      _saveRecentProducts();
    });
  }



  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = fetchSearchResults(query);
      });
    } else {
      setState(() {
        _searchResults = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Challenge Flutter',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _searchResults == null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historial reciente',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: recentProducts.isEmpty
                        ? Center(child: Text('No hay productos recientes'))
                        : ListView.builder(
                      itemCount: recentProducts.length,
                      itemBuilder: (context, index) {
                        final item = recentProducts[index];
                        return ListTile(
                          leading: Image.network(item['image']),
                          title: Text(item['title']),
                          subtitle: Text('${item['price']} Bs'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetails(
                                  product: item,
                                ),
                              ),
                            ).then((_) {
                              _addToRecentProducts(item);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
                  : FutureBuilder<List<Map<String, dynamic>>>(
                future: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No se encontraron productos'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return ListTile(
                          leading: Image.network(item['image']),
                          title: Text(item['title']),
                          subtitle: Text('${item['price']} Bs'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetails(
                                  product: item,
                                ),
                              ),
                            ).then((_) {
                              _addToRecentProducts(item);
                            });
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

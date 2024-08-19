import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetails({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product['image']),
            SizedBox(height: 16),
            Text(
              product['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${product['price']} Bs',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Text(product['condition'] ?? 'No tiene esa especificacion.'),
          ],
        ),
      ),
    );
  }
}

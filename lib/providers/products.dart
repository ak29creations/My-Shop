import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './product.dart';
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAllProducts() async {
    final url = Uri.https(
        'flutter-update-7810f-default-rtdb.firebaseio.com', '/products.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: prodData['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'flutter-update-7810f-default-rtdb.firebaseio.com', '/products.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProuct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    try {
      final url = Uri.https('flutter-update-7810f-default-rtdb.firebaseio.com',
          '/products/$id.json');
      await http.patch(
        url,
        body: json.encode({
          'title': newProuct.title,
          'price': newProuct.price,
          'description': newProuct.description,
          'imageUrl': newProuct.imageUrl,
        }),
      );
      _items[prodIndex] = newProuct;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('flutter-update-7810f-default-rtdb.firebaseio.com',
        '/products/$id.json');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}

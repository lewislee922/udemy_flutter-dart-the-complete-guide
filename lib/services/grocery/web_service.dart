import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../models/grocery.dart';

abstract class GroceryDataService<T> extends ChangeNotifier {
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> remove(T item);
  Future<void> getAllItems();
  List<T> get cachedItems;
}

class GroceryWebService extends GroceryDataService<GroceryItem> {
  final String url;
  List<GroceryItem> _cached = [];

  GroceryWebService(this.url);

  @override
  List<GroceryItem> get cachedItems => _cached;

  @override
  Future<void> add(GroceryItem item) async {
    final dio = Dio();
    final jsonData = item.toJson();
    try {
      final response = await dio.post('$url/groceries.json', data: jsonData);
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final key = responseData.keys.first;
        _cached.add(GroceryItem(
            id: responseData[key],
            name: item.name,
            quantity: item.quantity,
            category: item.category));
        notifyListeners();
      }
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> getAllItems() async {
    final dio = Dio();
    try {
      final response = await dio.get('$url/groceries.json');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final result = List<GroceryItem>.empty(growable: true);
        for (var key in data.keys) {
          result.add(GroceryItem(
              id: key,
              name: data[key]['name'],
              quantity: data[key]['quantity'],
              category: GroceryCategories.values.firstWhere((element) =>
                  element.title == (data[key]['category'] as String))));
        }
        _cached = result;
        notifyListeners();
      }
      _cached = [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> remove(GroceryItem item) async {
    final key = item.id;
    final dio = Dio();
    try {
      final response = await dio.delete('$url/groceries/$key.json');
      if (response.statusCode == 200) {
        _cached.remove(item);
        notifyListeners();
      }
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> update(GroceryItem item) async {
    final dio = Dio();
    final jsonData = item.toJson();
    try {
      final response =
          await dio.patch('$url/groceries/${item.id}.json', data: jsonData);
      if (response.statusCode == 200) {
        final index = _cached.indexOf(item);
        if (index != -1) {
          _cached[index] = item;
          notifyListeners();
        }
      }
    } on DioException {
      rethrow;
    }
  }
}

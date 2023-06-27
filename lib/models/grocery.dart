import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final GroceryCategories category;

  toJson() => {
        'name': name,
        'quantity': quantity,
        'category': category.title,
      };

  static const List<GroceryItem> avaliableItems = [
    GroceryItem(
        id: 'a', name: 'Milk', quantity: 1, category: GroceryCategories.dairy),
    GroceryItem(
        id: 'b',
        name: 'Bananas',
        quantity: 5,
        category: GroceryCategories.fruit),
    GroceryItem(
        id: 'c',
        name: 'Beef Steak',
        quantity: 1,
        category: GroceryCategories.meat),
  ];
}

// change Enum to Enhanced enum
enum GroceryCategories implements Equatable {
  vegetables('Vegetables', Color.fromARGB(255, 0, 255, 128)),
  fruit('Fruit', Color.fromARGB(255, 145, 255, 0)),
  meat('Meat', Color.fromARGB(255, 255, 102, 0)),
  dairy('Dairy', Color.fromARGB(255, 0, 208, 255)),
  carbs('Carbs', Color.fromARGB(255, 0, 60, 255)),
  sweets('Sweets', Color.fromARGB(255, 255, 149, 0)),
  spices('Spices', Color.fromARGB(255, 255, 187, 0)),
  convenience('Convenience', Color.fromARGB(255, 191, 0, 255)),
  hygiene('Hygiene', Color.fromARGB(255, 149, 0, 255)),
  other('Other', Color.fromARGB(255, 0, 225, 255));

  const GroceryCategories(this.title, this.color);

  final String title;
  final Color color;

  @override
  List<Object?> get props => [title, color];

  @override
  bool? get stringify => true;
}

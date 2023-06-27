import 'package:flutter/material.dart';

class SimpleErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  const SimpleErrorDialog(
      {super.key, required this.message, required this.title});
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
      );
}

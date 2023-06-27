import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ConnetcionErrorDialog extends StatelessWidget {
  final DioException error;

  const ConnetcionErrorDialog({super.key, required this.error});
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text("Network error"),
        content: Text(error.message ?? ''),
      );
}

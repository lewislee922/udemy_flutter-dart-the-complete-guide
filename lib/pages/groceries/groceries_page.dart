import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/main_page.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/groceries/connection_error_dialog.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

class Groceries extends ConsumerWidget {
  const Groceries({super.key});

  static Page page() => const MaterialPage(
      key: ValueKey('groceries'), name: 'groceries', child: Groceries());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webService = ref.watch(groceryWebService);
    return MainNavigationBar(
      extendBodyBehindAppBar: false,
      appBarTitle: const Text('Your Groceries'),
      actions: [
        IconButton(
            onPressed: () => ref.read(appState).changeNewGroceriesVisiblity(),
            icon: const Icon(Icons.add))
      ],
      child: ListView.builder(
        itemCount: webService.cachedItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            background: SizedBox.expand(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete),
              ),
            ),
            key: ValueKey(webService.cachedItems[index].id),
            onDismissed: (direction) async {
              if (direction == DismissDirection.endToStart) {
                try {
                  await webService.remove(webService.cachedItems[index]);
                } on DioException catch (e) {
                  ref.read(appState).changeNewGroceriesVisiblity();
                  showDialog(
                      context: context,
                      builder: (context) => ConnetcionErrorDialog(error: e));
                }
              }
            },
            child: ListTile(
              leading: Container(
                height: 20,
                width: 20,
                color: webService.cachedItems[index].category.color,
              ),
              title: Text(webService.cachedItems[index].name),
              trailing: Text("${webService.cachedItems[index].quantity}"),
            ),
          );
        },
      ),
    );
  }
}

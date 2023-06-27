import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/models/expense.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

import '../../main_page.dart';
import 'new_record_page.dart';

class EditCategory extends ConsumerWidget {
  const EditCategory({Key? key}) : super(key: key);

  static Page page() =>
      const MaterialPage(key: ValueKey("editcategory"), child: EditCategory());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainNavigationBar(
      appBarTitle: const Text(
        "Edit Category",
        style: TextStyle(color: Colors.white),
      ),
      appBarBackgroundColor: Colors.deepPurple,
      actions: [
        IconButton(
            onPressed: () {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    ExpenseCategory category =
                        ExpenseCategory(name: "", icon: 0);
                    return EditCategoryDialog(category: category);
                  });
            },
            icon: const Icon(Icons.add, color: Colors.white)),
        IconButton(
            onPressed: () => ref.read(appState).changeEditCategoryVisiblity(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            )),
      ],
      child: StreamBuilder<List<ExpenseCategory>>(
          stream: ref.watch(expanseDatabase).getAllCategory(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [
                  ...snapshot.data!.map((e) => Dismissible(
                        key: ValueKey(e.id),
                        secondaryBackground: SizedBox.expand(
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete),
                          ),
                        ),
                        background: SizedBox.expand(
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            child: const Icon(Icons.edit),
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  ExpenseCategory category = e;
                                  return EditCategoryDialog(
                                      category: category,
                                      title: "Edit Category");
                                });
                            return false;
                          }

                          if (direction == DismissDirection.endToStart) {
                            return true;
                          }

                          return false;
                        },
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            await ref
                                .read(expanseDatabase)
                                .removeCategory(e.id);
                          }
                        },
                        child: ListTile(
                          title: Text(e.name),
                          leading: Icon(
                              IconData(e.icon, fontFamily: "MaterialIcons")),
                        ),
                      ))
                ],
              );
            }
            return const Center(
              child: Text("No Category"),
            );
          }),
    );
  }
}

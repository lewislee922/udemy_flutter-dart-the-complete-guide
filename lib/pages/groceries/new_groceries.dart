import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/models/grocery.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/groceries/connection_error_dialog.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

class NewGroceriesPage extends Page {
  final Widget child;

  const NewGroceriesPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route createRoute(BuildContext context) {
    return ModalBottomSheetRoute(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        isDismissible: true,
        settings: this,
        builder: (context) => child,
        isScrollControlled: false);
  }
}

class NewGroceries extends ConsumerStatefulWidget {
  const NewGroceries({Key? key}) : super(key: key);

  static Page page() => const NewGroceriesPage(
      key: ValueKey('newgroceries'), child: NewGroceries());

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => NewGroceriesState();
}

class NewGroceriesState extends ConsumerState<NewGroceries> {
  late List<TextEditingController> _controllers;
  late GlobalKey<FormState> _formKey;
  GroceryCategories? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _controllers = List.generate(2, (index) => TextEditingController());
  }

  @override
  void deactivate() {
    ref.read(appState).whenNewGroceriesDismissed();
    super.deactivate();
  }

  @override
  void dispose() {
    for (var item in _controllers) {
      item.dispose();
    }
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(groceryWebService);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Please enter some text'
                  : null,
              controller: _controllers.first,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    validator: (value) => int.tryParse(value ?? "") == null
                        ? 'Please type digit currectly'
                        : null,
                    controller: _controllers.last,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: DropdownButton<GroceryCategories?>(
                    value: _selectedCategory,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Select"),
                        ),
                      ),
                      ...GroceryCategories.values
                          .map((e) => DropdownMenuItem<GroceryCategories?>(
                                value: e,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        color: e.color,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(e.name),
                                    ],
                                  ),
                                ),
                              ))
                    ],
                    onChanged: (category) =>
                        setState(() => _selectedCategory = category),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      for (final item in _controllers) {
                        item.text = "";
                      }

                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    child: const Text("Reset")),
                FilledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _selectedCategory != null) {
                        final gorceries = GroceryItem(
                            id: "",
                            quantity: int.parse(_controllers[1].text),
                            name: _controllers[0].text,
                            category: _selectedCategory!);
                        try {
                          await database.add(gorceries);
                        } on DioException catch (e) {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  ConnetcionErrorDialog(error: e));
                        }
                      }
                      ref.read(appState).changeNewGroceriesVisiblity();
                    },
                    child: const Text("Save"))
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_iconpicker_plus/flutter_iconpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/models/expense.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

class NewRecordPage extends Page {
  final Widget child;

  const NewRecordPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route createRoute(BuildContext context) {
    return ModalBottomSheetRoute(
        isDismissible: false,
        settings: this,
        builder: (context) => child,
        isScrollControlled: false);
  }
}

class NewRecord extends ConsumerStatefulWidget {
  const NewRecord({Key? key}) : super(key: key);

  static Page page() =>
      const NewRecordPage(key: ValueKey('newrecord'), child: NewRecord());
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => NewRecordState();
}

class NewRecordState extends ConsumerState<NewRecord> {
  late List<TextEditingController> _controllers;
  ExpenseCategory? _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(2, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var item in _controllers) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(expanseDatabase);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        children: [
          TextField(
            controller: _controllers.first,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: _controllers.last,
            decoration: const InputDecoration(labelText: "Amount"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  flex: 3,
                  child: StreamBuilder<List<ExpenseCategory>>(
                      stream: database.getAllCategory(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return DropdownButton<ExpenseCategory?>(
                              value: _selectedCategory,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text("Select"),
                                ),
                                ...snapshot.data!.map(
                                    (e) => DropdownMenuItem<ExpenseCategory?>(
                                          value: e,
                                          child: Row(
                                            children: [
                                              Icon(IconData(e.icon,
                                                  fontFamily: "MaterialIcons")),
                                              Text(e.name),
                                            ],
                                          ),
                                        ))
                              ],
                              onChanged: (category) =>
                                  setState(() => _selectedCategory = category));
                        }
                        return TextButton(
                          child: const Text("add new category"),
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
                        );
                      })),
              const SizedBox(width: 16.0),
              Flexible(
                  flex: 2,
                  child:
                      TextDatePicker(onChanged: (date) => _selectedDate = date))
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () =>
                      ref.read(appState).changeNewRecordVisiblity(),
                  child: const Text("Cancel")),
              FilledButton(
                  onPressed: () {
                    if (_controllers[0].text.isNotEmpty &&
                        _controllers[1].text.isNotEmpty &&
                        _selectedCategory != null &&
                        _selectedDate != null) {
                      final record = ExpenseRecord(
                          title: _controllers[0].text,
                          amount: double.parse(_controllers[1].text),
                          recordDate: _selectedDate!,
                          categoryId: _selectedCategory!.id);
                      database.addRecord(record);
                    }

                    ref.read(appState).changeNewRecordVisiblity();
                  },
                  child: const Text("Save"))
            ],
          )
        ],
      ),
    );
  }
}

class TextDatePicker extends StatefulWidget {
  final Function(DateTime?) onChanged;

  const TextDatePicker({super.key, required this.onChanged});

  @override
  State<StatefulWidget> createState() => TextDatePickerState();
}

class TextDatePickerState extends State<TextDatePicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: "Tap to select date"),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(DateTime.now().year),
              lastDate: DateTime.now());
          widget.onChanged(date);
          if (date != null) {
            final month = date.month.toString().length == 2
                ? date.month.toString()
                : "0${date.month}";
            final day = date.day.toString().length == 2
                ? date.day.toString()
                : "0${date.day}";
            _controller.text = "$day/$month/${date.year}";
          } else {
            _controller.text = "";
          }
        });
  }
}

class EditCategoryDialog extends ConsumerWidget {
  ExpenseCategory category;
  final String title;

  EditCategoryDialog({super.key, required this.category, String? title})
      : title = title ?? "New Category";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StatefulBuilder(builder: (context, newState) {
      return SimpleDialog(
          contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
          title: Text(title),
          children: [
            TextFormField(
              initialValue: category.name,
              onChanged: (value) => category.name = value,
              decoration: const InputDecoration(label: Text("name")),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Row(
              children: [
                category.icon != 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(IconData(category.icon,
                            fontFamily: "MaterialIcons")),
                      )
                    : const SizedBox(),
                OutlinedButton(
                    onPressed: () async {
                      final newIcon =
                          await FlutterIconPicker.showIconPicker(context);
                      if (newIcon != null) {
                        category.icon = newIcon.codePoint;
                      } else {
                        category.icon = 0;
                      }
                      newState(() => category.icon);
                    },
                    child: Text(category.icon != 0 ? "replace" : "choose"))
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                    onPressed: category.name != "" && category.icon != 0
                        ? () => ref
                            .read(expanseDatabase)
                            .addCategory(category)
                            .then((value) => Navigator.of(context).pop())
                        : null,
                    child: const Text("Add")),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"))
              ],
            )
          ]);
    });
  }
}

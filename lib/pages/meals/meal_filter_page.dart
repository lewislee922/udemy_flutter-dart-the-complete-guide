import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/main_page.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

class MealFilter extends ConsumerWidget {
  MealFilter({Key? key}) : super(key: key);

  static Page page() =>
      MaterialPage(key: const ValueKey('mealfilter'), child: MealFilter());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainNavigationBar(
      extendBodyBehindAppBar: false,
      appBarTitle: const Text("Your Filters"),
      appBarLeading: IconButton(
          onPressed: () => ref.read(appState).changeMealFilterVisiblity(),
          icon: const Icon(Icons.arrow_back)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            ..._titles.keys
                .map(
                  (key) => SwitchListTile(
                    value: ref.watch(appState).filterType[key]!,
                    onChanged: (value) =>
                        ref.read(appState).changeFilterType(key, value),
                    title: Text(_titles[key]!.first),
                    subtitle: Text(_titles[key]!.last),
                  ),
                )
                .toList()
          ],
        ),
      ),
    );
  }

  final _titles = {
    "gluten": ["Gluten-free", "Only include gluten-free meals."],
    "lactose": ["Lactose-free", "Only include lactose-free meals."],
    "vegetraian": ["Vegetarian", "Only include vegetarian meals."],
    "vegan": ["Vegan", "Only include vegan meals."],
  };
}

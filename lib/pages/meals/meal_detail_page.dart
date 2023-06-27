import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

import '../../main_page.dart';
import '../../models/meal.dart';

class MealDetail extends ConsumerWidget {
  final Meal meal;

  const MealDetail({
    Key? key,
    required this.meal,
  }) : super(key: key);

  static Page page(Meal meal) => MaterialPage(
      key: const ValueKey('mealdetail'), child: MealDetail(meal: meal));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isFav = ref.watch(appState).favoriteMeals.contains(meal);
    return MainNavigationBar(
      extendBodyBehindAppBar: false,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              onPressed: () {
                final result = ref.read(appState).favoriteMeal(meal);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(result ? "Meal added!" : "Meal removed!")));
              },
              icon: AnimatedSwitcher(
                switchInCurve: Curves.easeInCubic,
                switchOutCurve: Curves.easeOutCubic,
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation.drive(Tween<double>(begin: 0.6, end: 1.0)),
                  child: child,
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  key: ValueKey(isFav),
                ),
              )),
        )
      ],
      appBarTitle: Text(meal.title),
      appBarLeading: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            ref.read(appState).selectMeal(null);
          },
          icon: const Icon(Icons.arrow_back)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Column(
            children: [
              Hero(
                tag: meal.id,
                child: Image.network(meal.imageUrl,
                    height: size.height / 3,
                    width: size.width,
                    fit: BoxFit.cover),
              ),
              const SizedBox(height: 14),
              Text(
                'Ingredients',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16.0),
              for (final ingredient in meal.ingredients)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Text(
                    ingredient,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
              const SizedBox(height: 32.0),
              Text(
                'Steps',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16.0),
              for (final ingredient in meal.steps)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Text(
                    ingredient,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

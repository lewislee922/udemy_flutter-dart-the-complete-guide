import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/main_page.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/models/meal.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

class Meals extends ConsumerWidget {
  const Meals({super.key});

  static Page page() =>
      const MaterialPage(key: ValueKey('mealsdetail'), child: Meals());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(appState).filteredMeals;
    final size = MediaQuery.of(context).size;
    return MainNavigationBar(
      appBarLeading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => ref.read(appState).selectMealsCategory(null),
      ),
      child: detail != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView(
                children: [
                  ...detail.map((e) => SizedBox(
                        height: size.height / 3,
                        width: size.height / 3,
                        child: GestureDetector(
                            onTap: () => ref.read(appState).selectMeal(e),
                            child: MealCard(meal: e)),
                      ))
                ],
              ),
            )
          : const Center(child: Text("Not found")),
    );
  }
}

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textColor = Colors.white.withOpacity(0.7);
    final bodyStyle = TextStyle(color: textColor);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          SizedBox.expand(
            child: Hero(
              tag: meal.id,
              child: Image.network(
                meal.imageUrl,
                loadingBuilder: (_, child, ImageChunkEvent? event) {
                  return AnimatedOpacity(
                    opacity: event == null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent
              ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      meal.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: textColor),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer, color: textColor),
                        Text("${meal.duration} mins", style: bodyStyle),
                        const SizedBox(width: 4.0),
                        Icon(Icons.shopping_bag, color: textColor),
                        Text(meal.complexity.name, style: bodyStyle),
                        const SizedBox(width: 4.0),
                        Icon(Icons.attach_money, color: textColor),
                        Text(meal.affordability.name, style: bodyStyle),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

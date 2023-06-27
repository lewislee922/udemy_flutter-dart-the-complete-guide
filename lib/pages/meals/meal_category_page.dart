import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';
import '../../main_page.dart';
import '../../models/meal.dart';
import 'meals_page.dart';

class MealCategory extends ConsumerWidget {
  const MealCategory({super.key});

  static Page page() =>
      const MaterialPage(key: ValueKey('meals'), child: MealCategory());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        brightness == Brightness.light ? Colors.black : Colors.white;
    return MainNavigationBar(
      extendBodyBehindAppBar: false,
      actions: ref.watch(appState).mealTabIndex == 0
          ? [
              IconButton(
                  onPressed: () =>
                      ref.read(appState).changeMealFilterVisiblity(),
                  icon: const Icon(Icons.filter_list))
            ]
          : null,
      appBarTitle: Text(
        ref.watch(appState).mealTabIndex == 0
            ? "Pick your category"
            : "Your Favorites",
        style: TextStyle(color: textColor),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: ref.watch(appState).mealTabIndex,
          onTap: (value) => ref.read(appState).setNewTabIndex(value),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.set_meal), label: 'Categories'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
          ]),
      child: ref.watch(appState).mealTabIndex == 0
          ? const MealCategoryGridView()
          : const MealFavoriteView(),
    );
  }
}

class MealFavoriteView extends ConsumerWidget {
  const MealFavoriteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(appState).favoriteMeals;
    final size = MediaQuery.of(context).size;
    if (favorites.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            ...favorites.map((e) => SizedBox(
                  height: size.height / 3,
                  width: size.height / 3,
                  child: GestureDetector(
                      onTap: () => ref.read(appState).selectMeal(e),
                      child: MealCard(meal: e)),
                ))
          ],
        ),
      );
    }
    return Column(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Favorites",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            )),
        const Spacer(),
        Text("Uh oh ... nothing here!",
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12.0),
        const Text("Try selecting a different category!"),
        const Spacer()
      ],
    );
  }
}

class MealCategoryGridView extends ConsumerWidget {
  const MealCategoryGridView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: (MediaQuery.of(context).size.height - 200) / 5,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
          crossAxisCount: 2),
      children: [
        ...MealsCategory.avaliableCategories.map(
          (category) {
            final index = MealsCategory.avaliableCategories.indexOf(category);
            return AnimatedGridTile(
              key: ValueKey(category.id),
              duration: Duration(milliseconds: 250 + 35 * index),
              child: GestureDetector(
                onTap: () => ref.read(appState).selectMealsCategory(category),
                child: Container(
                  key: ValueKey(category.id),
                  decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(10.0)),
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    category.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AnimatedGridTile extends StatefulWidget {
  final Curve curve;
  final Duration duration;
  final Widget? child;

  const AnimatedGridTile(
      {Key? key,
      this.curve = Curves.bounceIn,
      this.duration = const Duration(milliseconds: 300),
      this.child})
      : super(key: key);

  @override
  State<AnimatedGridTile> createState() => AnimatedGridTileState();
}

class AnimatedGridTileState extends State<AnimatedGridTile>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SlideTransition(
      position: _controller.drive(
          Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, 0))),
      child: FadeTransition(
        opacity: _controller.drive(Tween<double>(begin: 0.3, end: 1.0)),
        child: widget.child,
      ),
    );
  }
}

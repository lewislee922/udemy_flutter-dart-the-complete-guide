import 'package:flutter/material.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/groceries/groceries_page.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/groceries/new_groceries.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/meals/meal_filter_page.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/your_places/new_place.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/your_places/place_detail.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/your_places/your_places.dart';

import '../models/meal.dart';
import '../models/place.dart';
import '../pages/chat/main.dart';
import '../pages/expense_tracker/edit_category_page.dart';
import '../pages/expense_tracker/expense_page.dart';
import '../pages/expense_tracker/new_record_page.dart';
import '../pages/meals/meal_category_page.dart';
import '../pages/meals/meal_detail_page.dart';
import '../pages/meals/meals_page.dart';
import '../pages/quiz/quiz_page.dart';
import '../pages/roll_dice/roll_dice_page.dart';

class AppRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  // 建議不要在get method 裡 create，不然會一直建立NavigatorState，造成動畫定位失誤
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final HeroController _controller = HeroController();

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();
  String _currentPath = 'rolldice';

  bool _newRecord = false;
  bool _newGroceries = false;
  bool _newPlace = false;

  bool _editCategory = false;
  bool _editFilter = false;

  List<Meal>? _filteredMeals;
  MealsCategory? _selectedCategory;
  Map<String, bool> filterType = {
    "gluten": false,
    "lactose": false,
    "vegetraian": false,
    "vegan": false
  };
  Meal? _selectedMeal;
  Place? _selectedPlace;
  int _mealTabIndex = 0;

  // final Map<String, bool> _defaultFilterType = {
  //   "gluten": false,
  //   "lactose": false,
  //   "vegetraian": false,
  //   "vegan": false
  // };

  List<Meal> favoriteMeals = List.empty(growable: true);

  List<Meal>? get filteredMeals => _filteredMeals;
  int get mealTabIndex => _mealTabIndex;

  void changeFilterType(String key, bool value) {
    if (filterType[key] != null && filterType[key] != value) {
      filterType[key] = value;
      notifyListeners();
    }
  }

  bool favoriteMeal(Meal meal) {
    final index = favoriteMeals.indexOf(meal);
    if (index != -1) {
      favoriteMeals.removeAt(index);
      notifyListeners();
      return false;
    } else {
      favoriteMeals.add(meal);
      notifyListeners();
      return true;
    }
  }

  void selectMeal(Meal? meal) {
    _selectedMeal = meal;
    notifyListeners();
  }

  void selectPlace(Place? place) {
    _selectedPlace = place;
    notifyListeners();
  }

  void setNewTabIndex(int index) {
    _mealTabIndex = index;
    notifyListeners();
  }

  void setNewPath(String path) {
    if (_currentPath != path) {
      _currentPath = path;
    }
    _resetExpenseState();
    _resetMealState();
    _resetGroceryState();
    _resetNewPlaceState();

    notifyListeners();
  }

  void _resetExpenseState() {
    _newRecord = false;
    _editCategory = false;
  }

  void _resetMealState() {
    _editFilter = false;
    _filteredMeals = null;
    _selectedCategory = null;
    _selectedMeal = null;
    _mealTabIndex = 0;
  }

  void _resetGroceryState() {
    _newGroceries = false;
  }

  void _resetNewPlaceState() {
    _newPlace = false;
    _selectedPlace = null;
  }

  void changeMealFilterVisiblity() {
    _editFilter = !_editFilter;
    notifyListeners();
  }

  void changeNewRecordVisiblity() {
    _newRecord = !_newRecord;
    notifyListeners();
  }

  void changeEditCategoryVisiblity() {
    _editCategory = !_editCategory;
    notifyListeners();
  }

  void changeNewGroceriesVisiblity() {
    _newGroceries = !_newGroceries;
    notifyListeners();
  }

  void whenNewGroceriesDismissed() {
    _newGroceries = !_newGroceries;
  }

  void changeNewPlaceVisiblity() {
    _newPlace = !_newPlace;
    notifyListeners();
  }

  void selectMealsCategory(MealsCategory? category) {
    _selectedCategory = category;
    if (_selectedCategory != null) {
      _filteredMeals = Meal.dummyMeals.where((meal) {
        if (meal.categories.contains(_selectedCategory!.id)) {
          if ((filterType["gluten"]! && !meal.isGlutenFree) ||
              (filterType["lactose"]! && !meal.isLactoseFree) ||
              (filterType["vegetraian"]! && !meal.isVegetarian) ||
              (filterType["vegan"]! && !meal.isVegan)) {
            return false;
          }
          return true;
        }
        return false;
      }).toList();
    } else {
      _filteredMeals = null;
    }
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: [_controller],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        return true;
      },
      pages: [
        if (_currentPath == 'rolldice') RollDice.page(),
        if (_currentPath == 'quiz') Quiz.page(),
        if (_currentPath == 'meals') MealCategory.page(),
        if (_editFilter) MealFilter.page(),
        if (_selectedCategory != null) Meals.page(),
        if (_selectedMeal != null) MealDetail.page(_selectedMeal!),
        if (_currentPath == 'expense') Expense.page(),
        if (_editCategory) EditCategory.page(),
        if (_newRecord) NewRecord.page(),
        if (_currentPath == 'groceries') Groceries.page(),
        if (_newGroceries) NewGroceries.page(),
        if (_currentPath == 'yourplaces') YourPlace.page(),
        if (_selectedPlace != null) PlaceDetail.page(_selectedPlace!),
        if (_newPlace) NewPlace.page(),
        if (_currentPath == 'chat') ChatMain.page()
      ],
    );
  }

  @override
  Future<bool> popRoute() async => false;

  @override
  Future<void> setNewRoutePath(String configuration) async {
    setNewPath(configuration);
  }
}

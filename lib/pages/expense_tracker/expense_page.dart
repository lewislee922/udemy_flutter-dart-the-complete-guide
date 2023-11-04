import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/main_page.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/models/expense.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

class Expense extends ConsumerWidget {
  const Expense({super.key});

  static Page page() =>
      const MaterialPage(key: ValueKey('expense'), child: Expense());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(expanseDatabase);
    return MainNavigationBar(
      extendBodyBehindAppBar: false,
      appBarBackgroundColor: Colors.deepPurple,
      appBarTitle: const Text(
        "Expanse Tracker",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          tooltip: "edit category",
          onPressed: () => ref.read(appState).changeEditCategoryVisiblity(),
          icon: const Icon(Icons.edit, color: Colors.white),
        ),
        IconButton(
          tooltip: "new record",
          onPressed: () => ref.read(appState).changeNewRecordVisiblity(),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.deepPurple.shade100,
                                Colors.deepPurple.shade200
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: const CategoryExpenseChart(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: StreamBuilder<List<ExpenseRecord>>(
                      stream: database.getAllRecord(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                              children: snapshot.data!
                                  .map((e) => ExpenseTile(record: e))
                                  .toList());
                        }
                        return const SizedBox();
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final ExpenseRecord record;

  const ExpenseTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd/MM/yyyy");
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.deepPurple.shade200),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text("\$${record.amount}"),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.shopping_basket_rounded),
              const SizedBox(width: 4.0),
              Text(dateFormat.format(record.recordDate))
            ],
          )
        ],
      ),
    );
  }
}

class CategoryExpenseChart extends ConsumerWidget {
  const CategoryExpenseChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(expanseDatabase);
    return StreamBuilder<List<ExpenseRecord>>(
        stream: database.getAllRecord(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<ExpenseCategory, double> result = {};
            final allCategories =
                ref.watch(expanseDatabase).getAllCategoriesSync();
            for (var item in allCategories) {
              final records = snapshot.data!
                  .where((element) => element.categoryId == item.id)
                  .fold<double>(
                      0.0,
                      (previousValue, element) =>
                          previousValue + element.amount);

              result[item] = records;
            }
            final sumAmount = result.values
                .fold(0.0, (previousValue, value) => previousValue + value);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...result.keys.map(
                  (e) => CategoryExpenseChartBar(
                    category: e,
                    totalAmount: result[e]!,
                    sumAmount: sumAmount,
                  ),
                )
              ],
            );
          }
          return const SizedBox();
        });
  }
}

class CategoryExpenseChartBar extends StatelessWidget {
  final ExpenseCategory category;
  final double totalAmount;
  final double sumAmount;
  const CategoryExpenseChartBar(
      {super.key,
      required this.category,
      required this.totalAmount,
      required this.sumAmount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          totalAmount == 0
              ? SizedBox(width: MediaQuery.of(context).size.width / 7)
              : Flexible(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      width: MediaQuery.of(context).size.width / 7,
                      height: constraints.maxHeight * (totalAmount / sumAmount),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0)),
                          color: Colors.deepPurple),
                    );
                  }),
                ),
          const SizedBox(height: 16.0),
          Icon(
            IconData(category.icon, fontFamily: "MaterialIcons"),
            color: Colors.deepPurple,
          )
        ],
      ),
    );
  }
}

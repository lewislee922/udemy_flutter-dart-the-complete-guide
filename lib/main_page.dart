import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider.dart';

class MainNavigationBar extends ConsumerWidget {
  final List<Widget>? actions;
  final Color? appBarBackgroundColor;
  final Color? backgroundColor;
  final bool? extendBodyBehindAppBar;
  final Widget? appBarTitle;
  final Widget? child;
  final Widget? appBarLeading;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  const MainNavigationBar(
      {super.key,
      this.actions,
      this.child,
      this.appBarTitle,
      this.appBarLeading,
      this.bottomNavigationBar,
      this.appBarBackgroundColor,
      this.backgroundColor,
      this.floatingActionButton,
      this.extendBodyBehindAppBar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Brightness brightness = Theme.of(context).brightness;
    final iconColor =
        brightness == Brightness.light ? Colors.black : Colors.white;
    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar ?? true,
      drawer: Drawer(
        child: Builder(builder: (context) {
          return Column(
            children: [
              DrawerHeader(
                child: Text(
                  "Udemy Course Demo",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                  onPressed: () {
                    ref.read(appState).setNewPath('rolldice');
                    Scaffold.of(context).closeDrawer();
                  },
                  child: const Text("RollDice")),
              TextButton(
                  onPressed: () {
                    ref.read(appState).setNewPath('quiz');
                    Scaffold.of(context).closeDrawer();
                  },
                  child: const Text("Quiz")),
              TextButton(
                  onPressed: () {
                    ref.read(appState).setNewPath('expense');
                    Scaffold.of(context).closeDrawer();
                  },
                  child: const Text("Expense")),
              TextButton(
                  onPressed: () {
                    ref.read(appState).setNewPath('meals');
                    Scaffold.of(context).closeDrawer();
                  },
                  child: const Text("Meals")),
              TextButton(
                  onPressed: () {
                    ref.read(appState).setNewPath('groceries');
                    Scaffold.of(context).closeDrawer();
                  },
                  child: const Text("Grocery")),
              TextButton(
                  onPressed: () {
                    ref.read(appState).setNewPath('yourplaces');
                    Scaffold.of(context).closeDrawer();
                  },
                  child: const Text("Your Places")),
              TextButton(
                  onPressed: () {
                    ref.read(appState).setNewPath('chat');
                    Scaffold.of(context).closeDrawer();
                  },
                  child: const Text("Chat")),
            ],
          );
        }),
      ),
      appBar: AppBar(
        foregroundColor: iconColor,
        shadowColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : null,
        leading: appBarLeading,
        title: appBarTitle,
        actions: actions,
        backgroundColor: appBarBackgroundColor ?? Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}

class MainPageContent extends ConsumerWidget {
  const MainPageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Router(routerDelegate: ref.watch(appState));
  }
}

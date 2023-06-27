import 'dart:math';

import 'package:flutter/material.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/main_page.dart';

class RollDice extends StatefulWidget {
  const RollDice({Key? key}) : super(key: key);

  static Page page() =>
      const MaterialPage(child: RollDice(), key: ValueKey('rolldice'));

  @override
  State<RollDice> createState() => RollDiceState();
}

class RollDiceState extends State<RollDice> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MainNavigationBar(
      child: SizedBox.expand(
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromARGB(255, 33, 194, 250),
                Color.fromARGB(255, 147, 28, 245),
              ])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: size.height / 2,
                  width: size.width / 2,
                  child: Image.asset('assets/images/dices/dice-$_index.png')),
              TextButton(
                  onPressed: () =>
                      setState(() => _index = Random().nextInt(6) + 1),
                  child: Text(
                    'Roll Dice!',
                    style: TextStyle(
                        fontSize: 24,
                        color: const Color.fromARGB(255, 33, 194, 250)
                            .withOpacity(0.6)),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

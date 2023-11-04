import 'package:flutter/material.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/main_page.dart';
import '/models/question.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  static Page page() =>
      const MaterialPage(key: ValueKey('quiz'), child: Quiz());

  @override
  State<Quiz> createState() => QuizState();
}

class QuizState extends State<Quiz> {
  final questions = QuizQuestion.sampleQuestions;
  final answers = List<String?>.generate(
      QuizQuestion.sampleQuestions.length, (index) => null);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MainNavigationBar(
      child: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromARGB(255, 33, 194, 250),
                Color.fromARGB(255, 147, 28, 245),
              ])),
          alignment: Alignment.center,
          width: size.width / 2,
          child: Navigator(
            onPopPage: (route, result) => route.didPop(result),
            pages: [
              QuizMainPage(
                size: size,
                pageChild: Builder(
                  builder: (context) {
                    return _createFrame(
                      context,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createFrame(BuildContext context) {
    int index = questions.length - 1;

    Widget? result;
    while (index >= 0) {
      final child = result;
      final currentIndex = index;
      result = QuestionFrame(
        question: questions[index],
        onPressed: (p0) {
          answers[currentIndex] = p0;
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, _, __) =>
                  child ??
                  QuizResultFrame(answers: answers, question: questions),
              transitionsBuilder:
                  (context, animation, backwardAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: backwardAnimation.drive(Tween<Offset>(
                      begin: const Offset(0, 0), end: const Offset(-1, 0))),
                  child: SlideTransition(
                    position: animation.drive(Tween<Offset>(
                        begin: const Offset(1, 0), end: const Offset(0, 0))),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      );
      index -= 1;
    }
    return result!;
  }
}

class QuizMainPage extends Page {
  final Size size;
  final Widget pageChild;

  const QuizMainPage({required this.size, required this.pageChild});

  @override
  Route createRoute(BuildContext context) => PageRouteBuilder(
        settings: this,
        pageBuilder: (context, animation, __) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: size.width / 2,
                height: size.height / 2,
                child: Image.asset(
                  'assets/images/quiz/quiz-logo.png',
                  color:
                      const Color.fromARGB(255, 147, 28, 245).withOpacity(0.4),
                )),
            const SizedBox(height: 16.0),
            const Text('Learn Flutter the fun way!',
                style: TextStyle(
                    fontSize: 24, color: Color.fromARGB(255, 108, 177, 215))),
            const SizedBox(height: 32),
            TextButton(
                onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, _, __) => pageChild,
                    transitionsBuilder:
                        (context, animation, backwardAnimation, child) =>
                            FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: backwardAnimation.drive(Tween<Offset>(
                                    begin: const Offset(0, 0),
                                    end: const Offset(-1, 0))),
                                child: child,
                              ),
                            ))),
                child: Text("→ Start Quiz",
                    style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 108, 177, 215)
                            .withOpacity(0.6))))
          ],
        ),
        transitionsBuilder: (context, animation, backwardAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: backwardAnimation.drive(Tween<Offset>(
                begin: const Offset(0, 0), end: const Offset(-1, 0))),
            child: child,
          ),
        ),
      );
}

class QuizResultFrame extends StatelessWidget {
  const QuizResultFrame(
      {super.key, required this.answers, required this.question});
  final List<String?> answers;
  final List<QuizQuestion> question;

  List<bool> _generateResult() {
    final result = List<bool>.empty(growable: true);
    for (var i = 0; i < question.length; i++) {
      result.add(question[i].answers.indexOf(answers[i]!) == 0);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final result = _generateResult();
    final size = MediaQuery.of(context).size;
    return Center(
      child: SizedBox(
        height: size.height / 1.5,
        width: size.width / 1.2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'You answered ${result.where((element) => element).length} out of ${question.length} questions currectly !',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                      question.length,
                      (index) => ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: result[index]
                                    ? const Color.fromARGB(255, 150, 198, 241)
                                    : const Color.fromARGB(255, 249, 133, 241),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: Text("${index + 1}"),
                            ),
                            title: Text(
                              question[index].text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(answers[index]!,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 202, 171, 252),
                                    )),
                                Text(
                                  question[index].answers.first,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 181, 254, 246),
                                  ),
                                )
                              ],
                            ),
                          )),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                label: const Text("Restart Quiz!"),
                icon: const Icon(Icons.refresh))
          ],
        ),
      ),
    );
  }
}

class QuestionFrame extends StatelessWidget {
  const QuestionFrame({Key? key, required this.question, this.onPressed})
      : super(key: key);

  final QuizQuestion question;
  final Function(String)? onPressed;

  @override
  Widget build(BuildContext context) {
    final shuffledAnswer = List.from(question.answers)..shuffle();
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                question.text,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            ...shuffledAnswer.map((e) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.4)),
                            onPressed: () => onPressed?.call(e),
                            child: Wrap(children: [Text(e)])),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

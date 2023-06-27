import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../main_page.dart';
import '../../models/expense.dart';
import '../../provider.dart';
import '../../services/chat/firebase_chat_auth.dart';
import '../../services/grocery/web_service.dart';
import '../../services/your_places/local_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open([ExpanseRecordSchema, ExpanseCategorySchema],
      directory: dir.path);
  await dotenv.load(fileName: ".env");
  final databasePath = await getDatabasesPath();
  final database = await openDatabase(
    p.join(databasePath, 'place.db'),
    version: 1,
    onCreate: (db, version) => db.execute(dotenv.get('ONCREATE')),
  );
  await Firebase.initializeApp();

  runApp(ProviderScope(overrides: [
    yourPlaceLocalService
        .overrideWith((ref) => PlaceLocalDataService(database)),
    expanseDatabase.overrideWith((ref) => ExpenseDatabase(isar)),
    groceryWebService.overrideWith(
        (ref) => GroceryWebService(dotenv.env['GROCERYURL']!)..getAllItems()),
    chatService.overrideWith((ref) => FirebaseChatAuth())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: false),
      home: const MainPageContent(),
    );
  }
}

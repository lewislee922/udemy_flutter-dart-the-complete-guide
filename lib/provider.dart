import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';

import 'models/expense.dart';
import 'models/grocery.dart';
import 'models/place.dart';
import 'route/delegate.dart';
import 'services/grocery/web_service.dart';
import 'services/your_places/local_service.dart';
import 'services/chat/chat_auth.dart';

final appState =
    ChangeNotifierProvider<AppRouterDelegate>((ref) => AppRouterDelegate());
final expanseDatabase =
    Provider<ExpenseDatabase>((ref) => throw UnimplementedError());
final groceryWebService =
    ChangeNotifierProvider<GroceryDataService<GroceryItem>>(
        (ref) => throw UnimplementedError());
final yourPlaceLocalService =
    Provider<LocalDataService<Place>>((ref) => throw UnimplementedError());
final chatService =
    Provider<ChatAuth<User, XFile>>((ref) => throw UnimplementedError());

class ExpenseDatabase {
  final Isar _isar;

  ExpenseDatabase(this._isar);

  Future<int> addRecord(ExpenseRecord record) async {
    return await _isar
        .writeTxn(() async => await _isar.expanseRecords.put(record));
  }

  removeRecord(int id) async {
    await _isar.writeTxn(() async => await _isar.expanseRecords.delete(id));
  }

  updateRecord(ExpenseRecord record) async {
    await _isar.writeTxn(() async => await _isar.expanseRecords.put(record));
  }

  Stream<List<ExpenseRecord>> getAllRecord() => _isar.expanseRecords
      .where()
      .sortByRecordDate()
      .watch(fireImmediately: true);

  Future<int> addCategory(ExpenseCategory category) async {
    return await _isar
        .writeTxn(() async => await _isar.expanseCategorys.put(category));
  }

  List<ExpenseCategory> getAllCategoriesSync() =>
      _isar.expanseCategorys.where().findAllSync();

  removeCategory(int id) async {
    await _isar.writeTxn(() async {
      final records = _isar.expanseRecords.filter().categoryIdEqualTo(id);
      await records.build().deleteAll();
      await _isar.expanseCategorys.delete(id);
    });
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    await _isar
        .writeTxn(() async => await _isar.expanseCategorys.put(category));
  }

  Stream<List<ExpenseCategory>> getAllCategory() =>
      _isar.expanseCategorys.where().watch(fireImmediately: true);
}

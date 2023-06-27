import '../../models/place.dart';
import 'package:sqflite/sqlite_api.dart';

abstract class LocalDataService<T> {
  Future<List<T>> getAll();
  void remove(T item);
  void add(T item);
  void update(T item);
}

class PlaceLocalDataService implements LocalDataService<Place> {
  final Database _db;

  PlaceLocalDataService(Database db) : _db = db;

  @override
  void add(Place item) async {
    await _db.insert('user_places', item.toMap());
  }

  @override
  Future<List<Place>> getAll() async {
    final data = await _db.query('user_places');
    return data.map((row) => Place.fromMap(row)).toList();
  }

  @override
  void remove(Place item) async {
    await _db.delete('user_places', where: 'id = ?', whereArgs: [item.id]);
  }

  @override
  void update(Place item) async {
    await _db.update('user_places', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }
  //final database;
}

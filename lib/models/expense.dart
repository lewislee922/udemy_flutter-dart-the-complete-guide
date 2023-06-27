import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
part 'expense.g.dart';

@collection
class ExpenseCategory extends Equatable {
  Id id = Isar.autoIncrement;
  String name;
  int icon;

  @ignore
  @override
  List<Object?> get props => [id];

  ExpenseCategory({required this.name, required this.icon});
}

@collection
class ExpenseRecord extends Equatable {
  Id id = Isar.autoIncrement;
  String title;
  int categoryId;
  double amount;
  DateTime recordDate;

  @ignore
  @override
  List<Object?> get props => [id];

  ExpenseRecord(
      {required this.title,
      required this.amount,
      required this.recordDate,
      required this.categoryId});
}

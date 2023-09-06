import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Department{
  final int? id;
  final String? name;

  Department({this.id, this.name});
}

class Group{
  final int? id;
  final String? name;
  final int? departmentId;

  Group({this.id, this.name, this.departmentId});
}

class Team{
  final int? id;
  final String? name;
  final int? groupId;

  Team({this.id, this.name, this.groupId});
}

class Employee{
  final int? id;
  final String? name;
  final String? extension;
  final String? email;
  final int? teamId;
  final int? groupId;

  Employee({this.id, this.name, this.extension, this.email, this.teamId, this.groupId});
}

Future<void> createTables(Database db) async {
  await db.execute('''
    CREATE TABLE department(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE group(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      department_id INTEGER,
      FOREIGN KEY(department_id) REFERENCES department(id)
    )
  ''');

  await db.execute('''
    CREATE TABLE team(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      group_id INTEGER,
      FOREIGN KEY(group_id) REFERENCES group(id)
    )
  ''');

  await db.execute('''
    CREATE TABLE employee(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      extension TEXT,
      email TEXT,
      team_id INTEGER,
      group_id INTEGER,
      FOREIGN KEY(team_id) REFERENCES team(id)
      FOREIGN KEY(group_id) REFERENCES group(id)
    )
  '''); 
}

Future<Database> initializeDB() async {
  String path = await getDatabasesPath();
  return openDatabase(
    join(path, 'employee.db'),
    onCreate: (database, version) async {
      await createTables(database);
    },
    version: 1
  );
}
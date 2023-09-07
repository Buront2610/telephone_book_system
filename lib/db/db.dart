import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class Department {
  final int id;
  final String name;
  List<Group> groups;
  List<Employee> employees;

  Department(this.id, this.name, {this.groups = const [], this.employees = const []});

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Group {
  final int id;
  final String name;
  final int departmentId;
  List<Team> teams;
  List<Employee> employees;

  Group(this.id, this.name, this.departmentId, {this.teams = const [], this.employees = const []});

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'department_id': departmentId,
    };
  }
}

class Team {
  final int id;
  final String name;
  final int groupId;
  List<Employee> employees;

  Team(this.id, this.name, this.groupId, {this.employees = const []});

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'group_id': groupId,
    };
  }
}

class Employee {
  final int id;
  final String name;
  final String extension;
  final String email;
  final int? departmentId;
  final int? groupId;
  final int? teamId;
  final bool isHide;

  Employee(this.id, this.name, this.extension, this.email, {this.departmentId, this.groupId, this.teamId, this.isHide = false});

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'extension': extension,
      'email': email,
      'department_id': departmentId,
      'group_id': groupId,
      'team_id': teamId,
      'is_hide': isHide,
    };
  }
}
// Create Table
Future<void> createTables(Database db) async {
  await db.execute('''
    CREATE TABLE department(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    )
  ''');

  await db.execute('''
    CREATE TABLE group_table(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      department_id INTEGER NOT NULL,
      FOREIGN KEY(department_id) REFERENCES department(id)
    )
  ''');

  await db.execute('''
    CREATE TABLE team(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      group_id INTEGER NOT NULL,
      FOREIGN KEY(group_id) REFERENCES group_table(id)
    )
  ''');

  await db.execute('''
    CREATE TABLE employee(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      extension TEXT,
      email TEXT,
      department_id INTEGER,
      group_id INTEGER,
      team_id INTEGER,
      is_hide BOOLEAN NOT NULL,
      FOREIGN KEY(department_id) REFERENCES department(id),
      FOREIGN KEY(group_id) REFERENCES group_table(id),
      FOREIGN KEY(team_id) REFERENCES team(id)
    )
  ''');
}


// CRUD with Hard-coded Data
Future<void> insertDepartment(Database db) async {
  final departmentList = [
    Department(1, '役員'),
    Department(2, '企画部'),
    Department(3, '水力システム部'),
    Department(4, '生産統括部'),
  ];
  for (var department in departmentList) {
    await db.insert(
      'department',
      department.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

Future<void> insertGroup(Database db) async {
  final groupList = [
    Group(1,'企画総務G',2),
    Group(2,'経営企画PJ',2),
    Group(3,'営業G',2),
    Group(4, '水力技術第1G', 3),
    Group(5, '水力技術第2G', 3),
    Group(6, '制御システムG',3),
    Group(7, '開発G',3),
    Group(8, '生産G',3),
    Group(9,'土木G', 3),
    Group(10,'営業技術・工事管理G',3),
    Group(11,'品質保証G',4),
    Group(12,'購買G',4),
  ];
  for(var group in groupList){
    await db.insert(
      'group_table',
      group.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
}

Future<void> insertTeam(Database db) async{
  final teamList = [
    Team(1,'製造チーム',8),
    Team(2,'生管チーム',8),
    Team(3,'管理業務T',8),
    Team(4,'土木制御T',8),
    Team(5,'品質管理T',11),
    Team(6,'品質検査T',11),
  ];
  for(var team in teamList){
    await db.insert(
      'team',
      team.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
}

Future<void> insertEmployee(Database db, Employee employee, employeeList) async{

  for(var employee in employeeList){
    await db.insert(
      'employee',
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
}
// Modified function to use new class definitions and handle potential issues
Future<List<Department>> getDepartments(Database db) async {
  try {
    final List<Map<String, dynamic>> maps = await db.query('department');
    return List.generate(maps.length, (i) {
      return Department(maps[i]['id'] as int, maps[i]['name'] as String);
    });
  } catch (e) {
    print("Error while getting departments: $e");
    return [];
  }
}

Future<List<Group>> getGroups(Database db) async {
  try {
    final List<Map<String, dynamic>> maps = await db.query('group');
    return List.generate(maps.length, (i) {
      return Group(maps[i]['id'] as int, maps[i]['name'] as String, maps[i]['department_id'] as int);
    });
  } catch (e) {
    print("Error while getting groups: $e");
    return [];
  }
}

Future<List<Team>> getTeams(Database db) async {
  try {
    final List<Map<String, dynamic>> maps = await db.query('team');
    return List.generate(maps.length, (i) {
      return Team(maps[i]['id'] as int, maps[i]['name'] as String, maps[i]['group_id'] as int);
    });
  } catch (e) {
    print("Error while getting teams: $e");
    return [];
  }
}

Future<List<Employee>> getEmployees(Database db) async {
  try {
    final List<Map<String, dynamic>> maps = await db.query('employee');
    return List.generate(maps.length, (i) {
      return Employee(
        maps[i]['id'] as int, 
        maps[i]['name'] as String, 
        maps[i]['extension'] as String, 
        maps[i]['email'] as String,
        departmentId: maps[i]['department_id'] as int?,
        groupId: maps[i]['group_id'] as int?,
        teamId: maps[i]['team_id'] as int?,
        isHide: maps[i]['is_hide'] as bool,
      );
    });
  } catch (e) {
    print("Error while getting employees: $e");
    return [];
  }
}


Future<List<Department>> updateDepartmentsFromDB(Database db) async {
  List<Department> dbDepartments = await getDepartments(db);
  List<Group> dbGroups = await getGroups(db);
  List<Team> dbTeams = await getTeams(db);
  List<Employee> dbEmployees = await getEmployees(db);

  // Exclude employees where isHide is true
  dbEmployees = dbEmployees.where((e) => !e.isHide).toList();

  // Update the departments list
  List<Department> departments = dbDepartments.map((dbDept) {
    // Get groups belonging to this department
    List<Group> deptGroups = dbGroups.where((g) => g.departmentId == dbDept.id).toList();

    // Populate the groups with their teams and employees
    deptGroups.forEach((group) {
      group.teams = dbTeams.where((t) => t.groupId == group.id).toList();
      group.teams.forEach((team) {
        team.employees = dbEmployees.where((e) => e.teamId == team.id && e.groupId == group.id && e.departmentId == dbDept.id).toList();
      });
      group.employees = dbEmployees.where((e) => e.groupId == group.id && e.departmentId == dbDept.id && e.teamId == null).toList();
    });

    // Get employees belonging directly to this department (not part of any group or team)
    List<Employee> deptEmployees = dbEmployees.where((e) => e.departmentId == dbDept.id && e.groupId == null && e.teamId == null).toList();

    return Department(dbDept.id, dbDept.name, groups: deptGroups, employees: deptEmployees);
  }).toList();
  return departments;

}


Future<Database> initializeDB() async {
  
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  String path = await getDatabasesPath();
  return openDatabase(
    join(path, 'employee.db'),
    onCreate: (database, version) async {
      await createTables(database);
      await insertDepartment(database);
      await insertGroup(database);
      await insertTeam(database);
    },
    version: 1
  );
}
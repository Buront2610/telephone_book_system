import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Department {
  final int id;
  final String name;
  List<Group> groups;
  List<Employee> employees;

  Department(this.id, this.name,
      {this.groups = const [], this.employees = const []});

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

  Group(this.id, this.name, this.departmentId,
      {this.teams = const [], this.employees = const []});

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
  final String position;
  final String extension;
  final String email;
  final List<int>? departmentIds;
  final List<int>? groupIds;
  final List<int>? teamIds;
  final bool isHide;

  Employee(this.id, this.name, this.position, this.extension, this.email,
      {this.departmentIds, this.groupIds, this.teamIds, this.isHide = false});

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'extension': extension,
      'email': email,
      'is_hide': isHide ? 1 : 0,
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
      position TEXT,
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

  await db.execute('''
    CREATE TABLE employee_department(
      employee_id INTEGER NOT NULL,
      department_id INTEGER NOT NULL,
      FOREIGN KEY(employee_id) REFERENCES employee(id),
      FOREIGN KEY(department_id) REFERENCES department(id)
    )
  ''');

  await db.execute('''
    CREATE TABLE employee_group(
      employee_id INTEGER NOT NULL,
      group_id INTEGER NOT NULL,
      FOREIGN KEY(employee_id) REFERENCES employee(id),
      FOREIGN KEY(group_id) REFERENCES group_table(id)
    )
  ''');

  await db.execute('''
    CREATE TABLE employee_team(
      employee_id INTEGER NOT NULL,
      team_id INTEGER NOT NULL,
      FOREIGN KEY(employee_id) REFERENCES employee(id),
      FOREIGN KEY(team_id) REFERENCES team(id)
    )
  ''');
}

// CRUD with Hard-coded Data
Future<void> setupInsertDepartment(Database db) async {
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

Future<void> setupInsertGroup(Database db) async {
  final groupList = [
    Group(1, '企画総務G', 2),
    Group(2, '経営企画PJ', 2),
    Group(3, '営業G', 2),
    Group(4, '水力技術第1G', 3),
    Group(5, '水力技術第2G', 3),
    Group(6, '制御システムG', 3),
    Group(7, '開発G', 3),
    Group(8, '生産G', 3),
    Group(9, '土木G', 3),
    Group(10, '営業技術・工事管理G', 3),
    Group(11, '品質保証G', 4),
    Group(12, '購買G', 4),
  ];
  for (var group in groupList) {
    await db.insert('group_table', group.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

Future<void> setupInsertTeam(Database db) async {
  final teamList = [
    Team(1, '製造チーム', 8),
    Team(2, '生管チーム', 8),
    Team(3, '管理業務T', 9),
    Team(4, '土木制御T', 9),
    Team(5, '品質管理T', 11),
    Team(6, '品質検査T', 11),
  ];
  for (var team in teamList) {
    await db.insert('team', team.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

Future<void> insertDepartment(Database db, departmentList) async {
  try {
    for (var department in departmentList) {
      await db.insert(
        'department',
        department.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  } catch (e) {
    debugPrint("Error while inserting departments: $e");
  }
}

Future<void> insertGroup(Database db, groupList) async {
  for (var group in groupList) {
    await db.insert('group_table', group.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

Future<void> insertTeam(Database db, teamList) async {
  for (var team in teamList) {
    await db.insert('team', team.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

Future<void> insertEmployee(Database db, employeeList) async {
  for (var employee in employeeList) {
    await db.insert('employee', employee.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    if (employee.departmentIds != null) {
      for (var departmentId in employee.departmentIds!) {
        await db.insert('employee_department',
            {'employee_id': employee.id, 'department_id': departmentId});
      }
    }

    if (employee.groupIds != null) {
      for (var groupId in employee.groupIds!) {
        await db.insert('employee_group',
            {'employee_id': employee.id, 'group_id': groupId});
      }
    }

    if (employee.teamIds != null) {
      for (var teamId in employee.teamIds!) {
        await db.insert(
            'employee_team', {'employee_id': employee.id, 'team_id': teamId});
      }
    }
  }
}

// CRUD with Hard-coded Data
Future<void> setupInsertEmployee(Database db) async {
  final employeeList = [
    Employee(1, 'Jim Doe', '代表取締役社長', '789', 'test@co.jp',
        departmentIds: [1], groupIds: [1], teamIds: [1]),
    // 新しい従業員データ
    Employee(2, 'Jane Smith', '技術者', '123', 'jane@co.jp',
        departmentIds: [2, 3], groupIds: [4, 5], teamIds: [1, 2]),
    Employee(3, 'John Doe', '営業', '456', 'john@co.jp',
        departmentIds: [2], groupIds: [2, 3], teamIds: [3, 4]),
    Employee(4, 'Mary Smith', '技術者', '789', 'Mary@co.jp',
        departmentIds: [2], groupIds: [4, 5], teamIds: []),

    // ... 他の従業員データ ...
  ];
  for (var employee in employeeList) {
    await db.insert('employee', employee.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    for (var departmentId in employee.departmentIds!) {
      await db.insert('employee_department',
          {'employee_id': employee.id, 'department_id': departmentId});
    }

    for (var groupId in employee.groupIds!) {
      await db.insert(
          'employee_group', {'employee_id': employee.id, 'group_id': groupId});
    }

    for (var teamId in employee.teamIds!) {
      await db.insert(
          'employee_team', {'employee_id': employee.id, 'team_id': teamId});
    }
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
    final List<Map<String, dynamic>> maps = await db.query('group_table');
    return List.generate(maps.length, (i) {
      return Group(maps[i]['id'] as int, maps[i]['name'] as String,
          maps[i]['department_id'] as int);
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
      return Team(maps[i]['id'] as int, maps[i]['name'] as String,
          maps[i]['group_id'] as int);
    });
  } catch (e) {
    debugPrint("Error while getting teams: $e");
    return [];
  }
}

Future<List<Employee>> getEmployees(Database db) async {
  try {
    final List<Map<String, dynamic>> maps = await db.query('employee');

    // Future.waitを使用して、全てのEmployeeオブジェクトが生成されるのを待つ
    return await Future.wait(maps.map((map) async {
      int employeeId = map['id'] as int;

      final List<Map<String, dynamic>> departmentMaps = await db.query(
          'employee_department',
          where: 'employee_id = ?',
          whereArgs: [employeeId]);
      List<int> departmentIds =
          departmentMaps.map((map) => map['department_id'] as int).toList();

      final List<Map<String, dynamic>> groupMaps = await db.query(
          'employee_group',
          where: 'employee_id = ?',
          whereArgs: [employeeId]);
      List<int> groupIds =
          groupMaps.map((map) => map['group_id'] as int).toList();

      final List<Map<String, dynamic>> teamMaps = await db.query(
          'employee_team',
          where: 'employee_id = ?',
          whereArgs: [employeeId]);
      List<int> teamIds = teamMaps.map((map) => map['team_id'] as int).toList();

      return Employee(
        employeeId,
        map['name'] as String,
        map['position'] as String,
        map['extension'] as String,
        map['email'] as String,
        departmentIds: departmentIds,
        groupIds: groupIds,
        teamIds: teamIds,
        isHide: map['is_hide'] == 1 ? true : false,
      );
    }).toList());
  } catch (e) {
    print("Error while getting employees: $e");
    return [];
  }
}

// Update department information
Future<void> updateDepartment(Database db, Department department) async {
  await db.update(
    'department',
    department.toDatabaseMap(),
    where: 'id = ?',
    whereArgs: [department.id],
  );
}

// Update group information
Future<void> updateGroup(Database db, Group group) async {
  await db.update(
    'group_table',
    group.toDatabaseMap(),
    where: 'id = ?',
    whereArgs: [group.id],
  );
}

// Update team information
Future<void> updateTeam(Database db, Team team) async {
  await db.update(
    'team',
    team.toDatabaseMap(),
    where: 'id = ?',
    whereArgs: [team.id],
  );
}

// Update employee information
Future<void> updateEmployee(Database db, Employee employee) async {
  await db.update(
    'employee',
    employee.toDatabaseMap(),
    where: 'id = ?',
    whereArgs: [employee.id],
  );
}

//delete data

// Delete all records from the "department" table
Future<void> deleteAllDepartments(Database db) async {
  await db.delete('department');
}

// Delete all records from the "group_table" table
Future<void> deleteAllGroups(Database db) async {
  await db.delete('group_table');
}

// Delete all records from the "team" table
Future<void> deleteAllTeams(Database db) async {
  await db.delete('team');
}

// Delete all records from the "employee" table
Future<void> deleteAllEmployees(Database db) async {
  await db.delete('employee');
}

// // Backup all records from the "department" table
// Future<void> backupDepartments(Database db) async {
//   List<Map<String, dynamic>> records = await db.query('department');
//   String jsonBackup = jsonEncode(records);
//   // Save this JSON string to a file or other backup storage
// }

// // Backup all records from the "group_table" table
// Future<void> backupGroups(Database db) async {
//   List<Map<String, dynamic>> records = await db.query('group_table');
//   String jsonBackup = jsonEncode(records);
//   // Save this JSON string to a file or other backup storage
// }

// // Backup all records from the "team" table
// Future<void> backupTeams(Database db) async {
//   List<Map<String, dynamic>> records = await db.query('team');
//   String jsonBackup = jsonEncode(records);
//   // Save this JSON string to a file or other backup storage
// }

// // Backup all records from the "employee" table
// Future<void> backupEmployees(Database db) async {
//   List<Map<String, dynamic>> records = await db.query('employee');
//   String jsonBackup = jsonEncode(records);
//   // Save this JSON string to a file or other backup storage
// }

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
    List<Group> deptGroups =
        dbGroups.where((g) => g.departmentId == dbDept.id).toList();

    // Populate the groups with their teams and employees
    deptGroups.forEach((group) {
      group.teams = dbTeams.where((t) => t.groupId == group.id).toList();
      group.teams.forEach((team) {
        team.employees = dbEmployees
            .where((e) => e.teamIds?.contains(team.id) ?? false)
            .toList();
      });
      group.employees = dbEmployees
          .where((e) => e.groupIds?.contains(group.id) ?? false)
          .toList();
    });

    // Get employees belonging directly to this department (not part of any group or team)
    List<Employee> deptEmployees = dbEmployees
        .where((e) =>
            e.departmentIds?.contains(dbDept.id) ??
            false &&
                (e.groupIds?.isEmpty ?? true) &&
                (e.teamIds?.isEmpty ?? true))
        .toList();

    return Department(dbDept.id, dbDept.name,
        groups: deptGroups, employees: deptEmployees);
  }).toList();

  for (var dept in departments) {
    exploreDepartment(dept);
  }
  return departments;
}

void exploreDepartment(Department department) {
  debugPrint('Department: ${department.name}');

  for (Group group in department.groups) {
    debugPrint('Group: ${group.name}');

    for (Team team in group.teams) {
      debugPrint('Team: ${team.name}');

      for (Employee employee in team.employees) {
        debugPrint('Employee in Team: ${employee.name}');
      }
    }

    for (Employee employee in group.employees) {
      debugPrint('Employee in Group: ${employee.name}');
    }
  }

  for (Employee employee in department.employees) {
    debugPrint('Employee in Department: ${employee.name}');
  }
}

Future<void> debugPrintDatabaseContents(Database db) async {
  List<Department> departments = await getDepartments(db);
  List<Group> groups = await getGroups(db);
  List<Team> teams = await getTeams(db);
  List<Employee> employees = await getEmployees(db);

  debugPrint("=== Debug Print of Database Contents ===");
  debugPrint("Departments:");
  for (var dept in departments) {
    debugPrint(dept.toDatabaseMap().toString());
  }

  debugPrint("Groups:");
  for (var group in groups) {
    debugPrint(group.toDatabaseMap().toString());
  }

  debugPrint("Teams:");
  for (var team in teams) {
    debugPrint(team.toDatabaseMap().toString());
  }

  debugPrint("Employees:");
  for (var employee in employees) {
    debugPrint(employee.toDatabaseMap().toString());
  }
  debugPrint("=== End of Debug Print ===");
}

String listToCsv(List<Map<String, dynamic>> records) {
  if (records.isEmpty) {
    return '';
  }

  final StringBuffer csvBuffer = StringBuffer();
  final List<String> header = records.first.keys.toList();

  csvBuffer.writeln(header.join(','));

  for (final record in records) {
    final List<String> values = record.values.map((e) => e.toString()).toList();
    csvBuffer.writeln(values.join(','));
  }
  return csvBuffer.toString();
}

// Convert Department object to CSV string
Future<String> departmentToCsv(List<Department> departments) async {
  StringBuffer buffer = StringBuffer();

  // Write header
  buffer.writeln("id,name"); // Header

  // Write department data
  for (var department in departments) {
    buffer.writeln("${department.id},${department.name}");
  }

  return buffer.toString();
}

Future<String> groupToCsv(List<Group> groups) async {
  StringBuffer buffer = StringBuffer();

  // Write header
  buffer.writeln("id,name,department_id"); // Header

  // Write group data
  for (var group in groups) {
    buffer.writeln("${group.id},${group.name},${group.departmentId}");
  }

  return buffer.toString();
}

// Convert Team object to CSV string
Future<String> teamToCsv(List<Team> teams) async {
  StringBuffer buffer = StringBuffer();

  // Write header
  buffer.writeln("id,name,group_id"); // Header

  // Write team data
  for (var team in teams) {
    buffer.writeln("${team.id},${team.name},${team.groupId}");
  }

  return buffer.toString();
}

Future<String> employeeToCsv(List<Employee> employees) async {
  StringBuffer buffer = StringBuffer();

  // Write header
  buffer.writeln(
      "id,name,position,extension,email,department_ids,group_ids,team_ids,is_hide"); // Headerを小文字に

  // Write employee data
  for (var employee in employees) {
    // Convert lists of IDs to string using pipe as a delimiter
    String departmentIds = employee.departmentIds?.join('|') ?? '';
    String groupIds = employee.groupIds?.join('|') ?? '';
    String teamIds = employee.teamIds?.join('|') ?? '';

    // Convert isHide to int (1 or 0)
    int isHide = employee.isHide ? 1 : 0;

    buffer.writeln(
        "${employee.id},${employee.name},${employee.position},${employee.extension},${employee.email},${departmentIds},${groupIds},${teamIds},${isHide}");
  }

  return buffer.toString();
}

// Export all Department objects as CSV
Future<String> exportDepartmentsToCsv(Database db) async {
  List<Department> departments = await getDepartments(db);
  List<String> csvList = [];
  csvList.add(await departmentToCsv(departments));

  return csvList.join('\n');
}

// Export all Group objects as CSV
Future<String> exportGroupsToCsv(Database db) async {
  List<Group> groups = await getGroups(db);
  List<String> csvList = [];
  csvList.add(await groupToCsv(groups));

  return csvList.join('\n');
}

// Export all Team objects as CSV
Future<String> exportTeamsToCsv(Database db) async {
  List<Team> teams = await getTeams(db);
  List<String> csvList = [];

  csvList.add(await teamToCsv(teams));

  return csvList.join('\n');
}

// Export all Employee objects as CSV
Future<String> exportEmployeesToCsv(Database db) async {
  List<Employee> employees = await getEmployees(db);
  List<String> csvList = [];
  csvList.add(await employeeToCsv(employees));
  return csvList.join('\n');
}

// Save CSV content to a file
Future<void> saveCsvToFile(
    String csvContent, String fileName, String directory) async {
  final File file = File(join(directory, '$fileName.csv'));
  await file.writeAsString(csvContent);
}

void exportToCSV(Database db) async {
  // パーミッションをリクエスト
  PermissionStatus status = await Permission.manageExternalStorage.request();
  debugPrint("Permission status: $status");
  if (!status.isGranted) {
    // パーミッションが許可されていない場合、リクエストする
    status = await Permission.manageExternalStorage.request();
    debugPrint("Permission status: $status");
  }

  if (status.isGranted) {
    // ユーザーにディレクトリを選ばせる
    String? directory = await FilePicker.platform.getDirectoryPath();

    if (directory != null) {
      // Export Departments
      final String departmentsCsv = await exportDepartmentsToCsv(db);
      debugPrint("Departments CSV:" + departmentsCsv);
      await saveCsvToFile(departmentsCsv, 'departments', directory);

      // Export Groups
      final String groupsCsv = await exportGroupsToCsv(db);
      debugPrint("Groups CSV:" + groupsCsv);
      await saveCsvToFile(groupsCsv, 'groups', directory);

      // Export Teams
      final String teamsCsv = await exportTeamsToCsv(db);
      debugPrint("Teams CSV:" + teamsCsv);
      await saveCsvToFile(teamsCsv, 'teams', directory);

      // Export Employees
      final String employeesCsv = await exportEmployeesToCsv(db);
      debugPrint("Employees CSV:" + employeesCsv);
      await saveCsvToFile(employeesCsv, 'employees', directory);
    } else {
      print("No directory selected");
    }
  } else {
    print("Storage permission is not granted");
  }
}

Future<void> requestPermission(Permission permission) async {
  PermissionStatus status = await permission.request();
  if (status.isGranted) {
    // パーミッションが許可された
    debugPrint("Permission granted");
  } else {
    // パーミッションが拒否された
    debugPrint("Permission denied");
  }
}

Future<Database> initializeDB() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  // String path = await getDatabasesPath();
  // debugPrint("Database path: $documentsDirectory.path");
  return openDatabase(join(documentsDirectory.path, 'telephone_books2.db'),
      onCreate: (database, version) async {
    await createTables(database);
    await setupInsertDepartment(database);
    await setupInsertGroup(database);
    await setupInsertTeam(database);
    await setupInsertEmployee(database);
    // Debug print the database contents
    await debugPrintDatabaseContents(database);
    debugPrint("Database created");
  }, version: 1);
}

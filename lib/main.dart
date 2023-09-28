import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'db/db.dart';
import 'csv/csv.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '電話番号一覧アプリ',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(23, 24, 75, 1),
        textTheme: TextTheme(
          headline5: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Database? _db;
  late Future<void> initialization;
  late List<Department> departments = [];
  List<Employee> currentEmployees = [];
  List<Employee> originalEmployees = [];
  List<Employee> allEmployees = [];
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialization = initialize();
    debugPrint('start');
  }

  Future<void> initialize() async {
    if (_db == null) {
      _db = await initializeDB();
    }
    Database db = _db!;
    departments = await updateDepartmentsFromDB(db);
    _resetAllEmployees();
    for (var department in departments) {
      exploreDepartment(department);
    }
  }

  void _resetAllEmployees() {
    allEmployees.clear();
    for (var department in departments) {
      allEmployees.addAll(department.employees);
      for (var group in department.groups) {
        allEmployees.addAll(group.employees);
        for (var team in group.teams) {
          allEmployees.addAll(team.employees);
        }
      }
    }
    allEmployees = allEmployees.toSet().toList();
  }

  void _filterEmployees(String query) {
    debugPrint("Query: " + query);
    if (query.isEmpty) {
      _resetAllEmployees();
      setState(() {
        currentEmployees = List.from(allEmployees);
      });
    } else {
      setState(() {
        currentEmployees = allEmployees
            .where((employee) =>
                employee.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('電話番号一覧アプリ',
                        style: TextStyle(
                            fontStyle: FontStyle.normal, fontSize: 20.0)),
                    SizedBox(width: 20),
                    Expanded(
                      child: AnimSearchBar(
                        width: 400,
                        textController: textController,
                        style: TextStyle(fontStyle: FontStyle.normal),
                        onSuffixTap: () {
                          setState(() {
                            textController.clear();
                            currentEmployees = List.from(originalEmployees);
                          });
                        },
                        rtl: true,
                        onSubmitted: (String value) {
                          debugPrint("onSubmitted value: " + value);
                          _filterEmployees(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              body: Row(
                children: [
                  _buildSideBar(),
                  _buildEmployeeList(),
                ],
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  Widget _buildSideBar() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Color.fromRGBO(23, 24, 75, 1),
        child: ListView(
          children: [
            Column(
              children: List.generate(departments.length, (index) {
                return _buildExpansionTile(
                  departments[index].name,
                  departments[index]
                      .groups
                      .map((group) => _buildGroupTile(group))
                      .toList(),
                  Icons.business,
                  departments[index],
                );
              }),
            ),
            _buildCSVReader(),
            _buildCSVExport(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: currentEmployees.length,
          itemBuilder: (context, index) {
            return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentEmployees[index].name,
                          style: Theme.of(context).textTheme.headline5),
                      Text('役職: ${currentEmployees[index].position}',
                          style: TextStyle(
                              fontStyle: FontStyle.normal, fontSize: 20.0)),
                      Text('内線番号（通常・携帯）: ${currentEmployees[index].extension}',
                          style: TextStyle(
                              fontStyle: FontStyle.normal, fontSize: 20.0)),
                      // Text('メールアドレス: ${currentEmployees[index].email}',
                      //     style: TextStyle(
                      //         fontStyle: FontStyle.normal, fontSize: 18.0)),
                    ],
                  ),
                ));
          },
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, List<Widget> children, IconData icon,
      Department department) {
    return ExpansionTile(
      leading: Icon(icon, color: Color.fromRGBO(234, 244, 252, 1)),
      title: Text(title,
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Color.fromRGBO(234, 244, 252, 1))),
      children: children,
      onExpansionChanged: (bool expanding) {
        if (expanding) {
          setState(() {
            currentEmployees = department.employees;
            originalEmployees = List.from(currentEmployees);
          });
        }
      },
    );
  }

  Widget _buildGroupTile(Group group) {
    List<Widget> children = [];
    children.addAll(group.teams.map((team) => _buildTeamTile(team)).toList());

    return ExpansionTile(
      leading: Icon(Icons.group, color: Color.fromRGBO(204, 226, 243, 1)),
      title: Text(group.name,
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Color.fromRGBO(234, 244, 252, 1))),
      children: children,
      onExpansionChanged: (bool expanding) {
        if (expanding) {
          setState(() {
            currentEmployees = group.employees;
          });
        }
      },
    );
  }

  Widget _buildTeamTile(Team team) {
    return ListTile(
      leading: Icon(Icons.group, color: Color.fromRGBO(234, 244, 252, 1)),
      title: Text(team.name,
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Color.fromRGBO(234, 244, 252, 1))),
      selected: currentEmployees == team.employees,
      onTap: () {
        setState(() {
          currentEmployees = team.employees;
        });
      },
    );
  }

  Widget _buildCSVReader() {
    return ListTile(
      leading: Icon(Icons.add_circle_outline,
          color: Color.fromRGBO(234, 244, 252, 1)),
      title: Text('データインポート',
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(234, 244, 252, 1))),
      onTap: () async {
        try {
          if (_db == null) {
            debugPrint("データベースが初期化されていません。");
            return;
          }
          Database db = _db!;

          // Step 1: Show table selection dialog
          String? selectedTable = await TableSelectionDialog().show(context);
          debugPrint("Selected table: " + selectedTable.toString());
          if (selectedTable == null) return; // User canceled the dialog

          // Step 2: File selection
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['csv'],
          );

          debugPrint("Selected file: " + result.toString());

          if (result != null && result.files.single.path != null) {
            final input = File(result.files.single.path!).openRead();
            final content = await input.transform(utf8.decoder).join();
            final lines = content
                .split(RegExp(r'\r?\n'))
                .where((line) => line.trim().isNotEmpty)
                .toList();

            final fields = <List<String>>[];
            var transformFields = <List<dynamic>>[];

            for (var line in lines) {
              debugPrint("Line: " + line.toString());
              fields.add(line.split(',').map((e) => e.trim()).toList());
            }

            // Step 3: Validate data
            final errorMessage = validateCsvData(fields, selectedTable);
            debugPrint("Is valid data: " + (errorMessage == null).toString());
            debugPrint("Fields: " + fields.toString());

            if (errorMessage != null) {
              // Show error message using SnackBar
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(errorMessage)));
              return;
            } else {
              transformFields =
                  validateAndTransformCsvData(fields, selectedTable);
              debugPrint(transformFields.toString());
            }

            if (transformFields.isNotEmpty) {
              switch (selectedTable) {
                case 'Department':
                  await deleteAllDepartments(db);
                  await insertDepartment(db, parseDepartments(transformFields));
                  break;
                case 'Group':
                  await deleteAllGroups(db);
                  await insertGroup(db, parseGroups(transformFields));
                  break;
                case 'Team':
                  await deleteAllTeams(db);
                  await insertTeam(db, parseTeams(transformFields));
                  break;
                case 'Employee':
                  await deleteAllEmployees(db);
                  await insertEmployee(db, parseEmployees(transformFields));
                  break;
              }
            }

            setState(() {
              initialization = initialize();
            });
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      },
    );
  }

  Widget _buildCSVExport() {
    return ListTile(
      leading: Icon(Icons.download, color: Color.fromRGBO(234, 244, 252, 1)),
      title: Text('データエクスポート',
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(234, 244, 252, 1))),
      onTap: () async {
        try {
          if (_db == null) {
            debugPrint("データベースが初期化されていません。");
            return;
          }
          Database db = _db!;
          exportToCSV(db);
        } catch (e) {
          debugPrint(e.toString());
        }
      },
    );
  }
}

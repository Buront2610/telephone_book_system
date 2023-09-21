import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'db/db.dart'; // Make sure this import path is correct
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
          headline5: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic),
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
  late final Database db;
  late List<Department> departments =[];
  List<Employee> currentEmployees = [];
  List<Employee> originalEmployees = [];
  List<Employee> allEmployees = [];
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('start');
    initialize();
  }

  Future<void> initialize() async {
    final database = await initializeDB();
    setState(() {
      db = database;
      debugPrintDatabaseContents(db);
    });
    final updatedDepartments = await updateDepartmentsFromDB(db);

    setState(() {
      departments = updatedDepartments;
      _resetAllEmployees();
    });
    for (var department in departments) {
      exploreDepartment(department);
    }
    debugPrint('end');
  }


  // 全てのDepartment（およびそれに属するGroupとTeam）からEmployeeを再取得してallEmployeesをリセットする関数
  void _resetAllEmployees() {
    allEmployees.clear();
    for (var department in departments) {
      allEmployees.addAll(department.employees);  // Departmentに直接属するEmployee
      for (var group in department.groups) {
        allEmployees.addAll(group.employees);  // Groupに属するEmployee
        for (var team in group.teams) {
          allEmployees.addAll(team.employees);  // Teamに属するEmployee
        }
      }
    }
    // 重複を削除
    allEmployees = allEmployees.toSet().toList();
  }

  // Add your initializeDB function here
  void _filterEmployees(String query) {
    debugPrint("Query: " + query);
    if (query.isEmpty) {
      _resetAllEmployees(); // 全てのEmployeeを再取得してリセット
      setState(() {
        currentEmployees = List.from(allEmployees);  // リセット
      });
    } else {
      setState(() {
        currentEmployees = allEmployees
            .where((employee) =>
                employee.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
      for (var employee in currentEmployees) {
        debugPrint("name:" + employee.name);
      }
      for (var employee in allEmployees) {
        debugPrint("name:" + employee.name);
      }
    }
      for (var employee in currentEmployees) {
        debugPrint("name:" + employee.name);
      }
      for (var employee in allEmployees) {
        debugPrint("name:" + employee.name);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('電話番号一覧アプリ'),
            SizedBox(width: 20),
            Expanded(
              child: AnimSearchBar(
                width: 400,
                textController: textController,
                style: TextStyle(fontStyle: FontStyle.normal),
                onSuffixTap: () {
                  setState(() {
                    textController.clear();
                    currentEmployees = List.from(originalEmployees);  // リセット
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
  }

  Widget _buildSideBar() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Color.fromRGBO(23, 24, 75, 1),
        child: ListView(
          children: [

            ListView.builder(
              shrinkWrap: true,
              itemCount: departments.length,
              itemBuilder: (context, index) {
                return _buildExpansionTile(
                  departments[index].name,
                  departments[index].groups.map((group) => _buildGroupTile(group)).toList(),
                  Icons.business,
                  departments[index], // Pass the Department object here
                );
              },
            ),


              _buildCSVReader(db),
              _buildCSVExport(db),
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
              child:ListTile(
              leading: Icon(Icons.person),
              title:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentEmployees[index].name, style: Theme.of(context).textTheme.headline5),
                  Text('役職: ${currentEmployees[index].position}', style: TextStyle(fontStyle: FontStyle.normal)),
                  Text('電話番号: ${currentEmployees[index].extension}', style: TextStyle(fontStyle: FontStyle.normal)),
                  Text('メールアドレス: ${currentEmployees[index].email}', style: TextStyle(fontStyle: FontStyle.normal)),
                ],
              ),
            ));
          },
        ),
      ),
    );
  }

Widget _buildExpansionTile(String title, List<Widget> children, IconData icon, Department department) {
  return ExpansionTile(
    leading: Icon(icon, color: Color.fromRGBO(234,244,252,1)),
    title: Text(title, style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color: Color.fromRGBO(234,244,252,1))),
    children: children,
    onExpansionChanged: (bool expanding) {
      if (expanding) {
        setState(() {
          currentEmployees = department.employees;
          originalEmployees = List.from(currentEmployees);  // 元のリストを保存
        });
      }
    },
  );
}



  Widget _buildGroupTile(Group group) {
    // Teams and employees under this group
    List<Widget> children = [];

    // Add team tiles
    children.addAll(group.teams.map((team) => _buildTeamTile(team)).toList());

    return ExpansionTile(
      leading: Icon(Icons.group, color: Color.fromRGBO(204, 226, 243, 1)),
      title: Text(group.name, style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color:Color.fromRGBO(234,244,252,1))),
      children: children,
      onExpansionChanged: (bool expanding) {
        if (expanding) { 
          // only when the tile is being expanded
          print("Expanding, new employee list length: ${group.employees.length}");

          setState(() {
            currentEmployees = group.employees;
          });
        }
      },
    );
  }




  Widget _buildTeamTile(Team team) {
    return ListTile(
      leading: Icon(Icons.group, color:Color.fromRGBO(234,244,252,1)),
      title: Text(team.name, style: TextStyle(fontStyle: FontStyle.normal ,fontWeight: FontWeight.bold, color:Color.fromRGBO(234,244,252,1))),
      selected: currentEmployees == team.employees,
      onTap: () {
        setState(() {
          currentEmployees = team.employees;
        });
      },
    );
  }

    
  Widget _buildEmployeeTile(Employee employee) {
    return ListTile(
      leading: Icon(Icons.person, color:Color.fromRGBO(234,244,252,1)),
      title: Text(employee.name),
      onTap: () {
        // Handle employee tap if necessary
      },
    );
  }

  Widget _buildCSVReader(Database db) {
    return ListTile(
      leading: Icon(Icons.add_circle_outline, color:Color.fromRGBO(234,244,252,1)),
      title: Text('データインポート', style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color:Color.fromRGBO(234,244,252,1))),
      onTap: () async{
        try {
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
            final content = await input.transform(utf8.decoder).join();  // ファイルの全内容を一つのStringに読み込む
            final lines = content.split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty).toList();  // \r\n または \n で行に分割

            final fields = <List<String>>[];
            var transformFields = <List<dynamic>>[];

            for (var line in lines) {
              debugPrint("Line: " + line.toString());
              fields.add(line.split(',').map((e) => e.trim()).toList());
            }

            // Step 3: Validate data
            final isValidData = validateCsvData(fields, selectedTable); // Implement this function
            debugPrint("Is valid data: " + isValidData.toString());
            debugPrint("Fields: " + fields.toString());

            if (!isValidData) {
              // Show error message or dialog
              return;
            }
            else{
              transformFields = validateAndTransformCsvData(fields, selectedTable);
              debugPrint(transformFields.toString());
            }
            if(transformFields!=[]){
              switch (selectedTable) {
                case 'Department':
                  await deleteAllDepartments(db);
                  await insertDepartment(db, parseDepartments(transformFields)); // Implement this function
                  break;
                case 'Group':
                  await deleteAllGroups(db);
                  await insertGroup(db, parseGroups(transformFields)); // Implement this function
                  break;
                case 'Team':
                  await deleteAllTeams(db);
                  await insertTeam(db, parseTeams(transformFields)); // Implement this function
                  break;
                case 'Employee':
                  await deleteAllEmployees(db);
                  await insertEmployee(db, parseEmployees(transformFields)); // Implement this function
                  break;
              }
            }
            //AllEmployeesのアップデート
            initialize();
          }
        } catch(e) {
          debugPrint(e.toString());
        }
        // Handle employee tap if necessary
      },
    );
  }




  Widget _buildCSVExport(Database db){
    return ListTile(
      leading: Icon(Icons.download, color:Color.fromRGBO(234,244,252,1)),
      title: Text('データエクスポート', style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color:Color.fromRGBO(234,244,252,1))),
      onTap: () async{
        try{
          exportToCSV(db);

        }
        catch(e){
          debugPrint(e.toString());
        }
      },
    );
  }

}
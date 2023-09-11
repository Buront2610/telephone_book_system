import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'db/db.dart'; // Make sure this import path is correct

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


              _buildCSVReader(),
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

Widget _buildCSVReader() {
  return ListTile(
    leading: Icon(Icons.add_circle_outline, color:Color.fromRGBO(234,244,252,1)),
    title: Text('データインポート', style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color:Color.fromRGBO(234,244,252,1))),
    onTap: () async{
      try{
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );
        if(result != null && result.files.single.path != null){
          final input = File(result.files.single.path!).openRead();
          final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();
          debugPrint(fields.toString());

        }
      }catch(e){
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
// class Group {
//   final String name;
//   final List<Team> teams;
//   final List<Employee> employees;

//   Group(this.name, this.teams, [List<Employee>? employees])
//   : this.employees = employees ?? [];
// }

// class Team {
//   final String name;
//   final List<Employee> employees;

//   Team(this.name, this.employees);
// }

// class Employee {
//   final String name;
//   final String extension;
//   final String email;
//   final String position;

//   Employee(this.name, this.extension, this.email, this.position);
// }

// class Department {
//   final String name;
//   final List<Group> groups;

//   Department(this.name, this.groups);
// }

// // Dummy data
// List<Department> departments = [
//   Department('企画部', [
//     Group('役員', [], [
//       Employee('Jim Doe', '789','test@test.co.jp', 'president'),
//       Employee('Jim Doe', '789','test@test.co.jp', 'president'),
//       Employee('Jim Doe', '789','test@test.co.jp', 'president'),
    
//     ]),
//     Group('企画総務G', [
//       Team('Team 1', [
//         Employee('John Doe', '123', 'test@test.co.jp', 'Manager'),
//         Employee('Jim Doe', '789','test@test.co.jp', 'president'),

//       ]),
//       Team('Team 2', [
//         Employee('Jane Doe', '456', 'test@test.co.jp', 'Manager'),
//       ]),
//     ], [
//       Employee('John Doe', '123','sugoi@test.co.jp', 'Manager'),  // <-- ここをemployeesリストに追加
//     ]),
//   ]),
//   Department('Marketing', [
//     Group('Group 1', [
//       Team('Team 1', [
//         Employee('Jim Doe', '789','test@test.co.jp', 'Manager'),
//       ]),
//       Team('Team 2', [
//         Employee('Jill Doe', '321','test@test.co.jp', 'Manager'),
//       ]),
//     ]),
//   ]),
// ];


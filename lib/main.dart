import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
// import 'db/db.dart'

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: '電話番号一覧アプリ',
      color: Color.fromRGBO(23, 24, 75, 1),
      theme: ThemeData(
        primaryColor: Color.fromRGBO(23, 24, 75, 1),
        // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
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

  @override
  void initState() {
    super.initState();

    originalEmployeesList = [
      // Sample data
      Employee('John Doe', '1234', 'Manager', 'john.doe@example.com'),
      // Add other employees here
    ];
    currentEmployees = List.from(originalEmployeesList);

  }
  List<Employee> currentEmployees = [];
  List<Employee> originalEmployeesList = [];
  int? selectedTeamIndex;

  _filterEmployees(String query) {
    if (query.isNotEmpty) {
      setState(() {
        currentEmployees = currentEmployees.where((employee) => employee.name.contains(query)).toList();
      });
    } else {
      // Reset the employees list if the query is empty. Make sure to have a backup of the original list.
      setState(() {
        currentEmployees = List.from(originalEmployeesList);  // originalEmployeesList should be defined and store the initial list.
      });
    }
  }



  TextEditingController textController = TextEditingController();



Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color.fromRGBO(23, 24, 75, 1), // 背景
    appBar: AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Text('電話番号一覧アプリ', style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color: Color.fromRGBO(234,244,252,1))),
          SizedBox(width: 20), // 20ピクセルのスペースを追加
          Expanded( // 残りのスペースを使う
            child: AnimSearchBar(
              width: 400,
              textController: textController,
              onSuffixTap: () {
                setState(() {
                  textController.clear();
                });
              },
              rtl: true,
              onSubmitted: (String value) {
                debugPrint("onSubmitted value: " + value);
              },
            ),
          ),
        ],
      ),
    ),
        // textInputAction: TextInputAction.search,
      body: Row(
        children: <Widget>[
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
        child: ListView.builder(
          itemCount: departments.length,
          itemBuilder: (context, index) {
            return _buildExpansionTile(departments[index].name, departments[index].groups.map((group) => _buildGroupTile(group)).toList(), Icons.business);
          },
        ),
      ),
    );
  }

  Widget _buildAnimSeachBar(){
    return AnimSearchBar(
      width: 300,
      textController: textController,
      onSuffixTap: () {
        setState(() {
          textController.clear();
        });
      },
      rtl: true,
      onSubmitted: (String value) {
        debugPrint("onSubmitted value: " + value);
      },
      // textInputAction: TextInputAction.search,
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

  Widget _buildExpansionTile(String title, List<Widget> children, IconData icon) {
    return ExpansionTile(
      leading: Icon(icon, color: Color.fromRGBO(234,244,252,1)),
      title: Text(title, style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color: Color.fromRGBO(234,244,252,1))),
      children: children,
    );
  }


Widget _buildGroupTile(Group group) {
  // Teams and employees under this group
  List<Widget> children = [];

  // Add team tiles
  children.addAll(group.teams.map((team) => _buildTeamTile(team)).toList());

  return ExpansionTile(
    leading: Icon(Icons.group, color: Color.fromRGBO(234,244,252,1)),
    title: Text(group.name, style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color:Color.fromRGBO(234,244,252,1))),
    children: children,
    onExpansionChanged: (bool expanding) {
      if (expanding) {  // only when the tile is being expanded
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

}
class Group {
  final String name;
  final List<Team> teams;
  final List<Employee> employees;

  Group(this.name, this.teams, [List<Employee>? employees])
  : this.employees = employees ?? [];
}

class Team {
  final String name;
  final List<Employee> employees;

  Team(this.name, this.employees);
}

class Employee {
  final String name;
  final String extension;
  final String email;
  final String position;

  Employee(this.name, this.extension, this.email, this.position);
}

class Department {
  final String name;
  final List<Group> groups;

  Department(this.name, this.groups);
}

// Dummy data
List<Department> departments = [
  Department('企画部', [
    Group('役員', [], [
      Employee('Jim Doe', '789','test@test.co.jp', 'president'),
    ]),
    Group('企画総務G', [
      Team('Team 1', [
        Employee('John Doe', '123', 'test@test.co.jp', 'Manager'),
      ]),
      Team('Team 2', [
        Employee('Jane Doe', '456', 'test@test.co.jp', 'Manager'),
      ]),
    ], [
      Employee('John Doe', '123','sugoi@test.co.jp', 'Manager'),  // <-- ここをemployeesリストに追加
    ]),
  ]),
  Department('Marketing', [
    Group('Group 1', [
      Team('Team 1', [
        Employee('Jim Doe', '789','test@test.co.jp', 'Manager'),
      ]),
      Team('Team 2', [
        Employee('Jill Doe', '321','test@test.co.jp', 'Manager'),
      ]),
    ]),
  ]),
];
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Phone Directory App',
      theme: ThemeData(
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
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



  TextEditingController _searchController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        
      appBar: AppBar(
        title: Text('電話番号一覧'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _filterEmployees(value);
                });
              },
            ),
          ),
        ),
      ),

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
        color: Colors.blue[100],
        child: ListView.builder(
          itemCount: departments.length,
          itemBuilder: (context, index) {
            return _buildExpansionTile(departments[index].name, departments[index].groups.map((group) => _buildGroupTile(group)).toList(), Icons.business);
          },
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Expanded(
      flex: 2,
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: currentEmployees.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.all(8.0),
              child:ListTile(
              leading: Icon(Icons.person),
              title: Text(currentEmployees[index].name, style: Theme.of(context).textTheme.headline5),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Position: ${currentEmployees[index].position}'),
                  Text('Extension: ${currentEmployees[index].extension}'),
                  Text('Email: ${currentEmployees[index].email}'),
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
      leading: Icon(icon),
      title: Text(title),
      children: children,
    );
  }

  Widget _buildGroupTile(Group group) {
    return _buildExpansionTile(group.name, group.teams.map((team) => _buildTeamTile(team)).toList(), Icons.group);
  }

  Widget _buildTeamTile(Team team) {
    return ListTile(
      leading: Icon(Icons.group),
      title: Text(team.name),
      selected: currentEmployees == team.employees,
      onTap: () {
        setState(() {
          currentEmployees = team.employees;
        });
      },
    );
  }
}

class Department {
  final String name;
  final List<Group> groups;

  Department(this.name, this.groups);
}

class Group {
  final String name;
  final List<Team> teams;

  Group(this.name, this.teams);
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

// Dummy data
List<Department> departments = [
  Department('Sales', [
    Group('Group 1', [
      Team('Team 1', [
        Employee('John Doe', '123', 'test@test.co.jp', 'Manager'),
      ]),
      Team('Team 2', [
        Employee('Jane Doe', '456', 'test@test.co.jp', 'Manager'),
      ]),
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
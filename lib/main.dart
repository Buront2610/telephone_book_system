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
        primarySwatch: Colors.blue,
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
  List<Employee> currentEmployees = [];
  int? selectedTeamIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('電話番号一覧'),
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
            return ListTile(
              leading: Icon(Icons.person),
              title: Text(currentEmployees[index].name, style: Theme.of(context).textTheme.headline5),
              subtitle: Text('Extension: ${currentEmployees[index].extension}', style: Theme.of(context).textTheme.subtitle1),
            );
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

  Employee(this.name, this.extension);
}

// Dummy data
List<Department> departments = [
  Department('Sales', [
    Group('Group 1', [
      Team('Team 1', [
        Employee('John Doe', '123'),
      ]),
      Team('Team 2', [
        Employee('Jane Doe', '456'),
      ]),
    ]),
  ]),
  Department('Marketing', [
    Group('Group 1', [
      Team('Team 1', [
        Employee('Jim Doe', '789'),
      ]),
      Team('Team 2', [
        Employee('Jill Doe', '321'),
      ]),
    ]),
  ]),
];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Directory App'),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue[100],
              child: ListView.builder(
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(departments[index].name),
                    children: departments[index].groups.map((group) => _buildGroupTile(group)).toList(),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: currentEmployees.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(currentEmployees[index].name),
                    subtitle: Text('Extension: ${currentEmployees[index].extension}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(Group group) {
    return ExpansionTile(
      title: Text(group.name),
      children: group.teams.map((team) => _buildTeamTile(team)).toList(),
    );
  }

  Widget _buildTeamTile(Team team) {
    return ListTile(
      title: Text(team.name),
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

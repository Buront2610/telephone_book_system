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

class MyHomePage extends StatelessWidget {
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
                  return ListTile(
                    title: Text(departments[index].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupPage(department: departments[index]),
                        ),
                      );
                    },
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
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(employees[index].name),
                    subtitle: Text('Extension: ${employees[index].extension}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeePage(employee: employees[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupPage extends StatelessWidget {
  final Department department;

  GroupPage({Key key, @required this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${department.name} Groups'),
      ),
      body: ListView.builder(
        itemCount: department.groups.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(department.groups[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamPage(group: department.groups[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TeamPage extends StatelessWidget {
  final Group group;

  TeamPage({Key key, @required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${group.name} Teams'),
      ),
      body: ListView.builder(
        itemCount: group.teams.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(group.teams[index].name),
            onTap: () {
              // Handle team selection
            },
          );
        },
      ),
    );
  }
}

class EmployeePage extends StatelessWidget {
  final Employee employee;

  EmployeePage({Key key, @required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee.name),
      ),
      body: Column(
        children: <Widget>[
          Text('Name: ${employee.name}'),
          Text('Extension: ${employee.extension}'),
          // Add more details as needed
        ],
      ),
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

  Team(this.name);
}

class Employee {
  final String name;
  final String extension;

  Employee(this.name, this.extension);
}

// Dummy data
List<Department> departments = [
  Department('Sales', [Group('Group 1', [Team('Team 1'), Team('Team 2')])]),
  Department('Marketing', [Group('Group 1', [Team('Team 1'), Team('Team 2')])]),
];
List<Employee> employees = [
  Employee('John Doe', '123'),
  Employee('Jane Doe', '456'),
  Employee('Jim Doe', '789'),
];

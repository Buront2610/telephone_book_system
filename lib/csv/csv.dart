import 'package:flutter/material.dart';
import '../db/db.dart';

bool isInt(String? s){
  if(s == null) return false;
  return int.tryParse(s) != null;
}


//CSVデータの判定処理
List<List<dynamic>>? validCsvData(List<List<dynamic>> fields, String selectedTable) {
  if (fields.isEmpty) return null;

  List<dynamic> header = fields.first.map((e) => e.toString().trim()).toList();
  debugPrint("Header elements:");
  for (var element in header) {
    debugPrint("Element: [$element]");
  }

  List<List<dynamic>> transformedFields = [];

  switch (selectedTable) {
    case 'Department':
      for (var row in fields.sublist(1)) {
        if (!isInt(row[0]) || row[1] is! String){
          debugPrint('Incorrect types');
          return null;
        }
        transformedFields.add([int.parse(row[0]), row[1]]);
      }
      break;

    case 'Group':
      for (var row in fields.sublist(1)) {
        if (!isInt(row[0]) || row[1] is! String || !isInt(row[2])) {
          debugPrint('Incorrect types');
          return null;
        }
        transformedFields.add([int.parse(row[0]), row[1], int.parse(row[2])]);
      }
      break;

    case 'Team':
      for (var row in fields.sublist(1)) {
        if (!isInt(row[0]) || row[1] is! String || !isInt(row[2])) {
          debugPrint('Incorrect types');
          return null;
        }
        transformedFields.add([int.parse(row[0]), row[1], int.parse(row[2])]);
      }
      break;

    case 'Employee':
      for (var row in fields.sublist(1)) {
        if (!isInt(row[0]) || row[1] is! String || row[2] is! String || row[3] is! String || row[4] is! String) {
          debugPrint('Incorrect types');
          return null;
        }
        transformedFields.add([
          int.parse(row[0]), row[1], row[2], row[3], row[4],
          isInt(row[5]) ? int.parse(row[5]) : null,
          isInt(row[6]) ? int.parse(row[6]) : null,
          isInt(row[7]) ? int.parse(row[7]) : null,
          int.parse(row[8])
        ]);
      }
      break;
  }
  
  return transformedFields;
}





class TableSelectionDialog extends StatelessWidget {
  Future<String?> show(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return this;
      },
    );
  }
  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: Text('データ編集項目を選択してください', style: TextStyle(fontStyle:FontStyle.normal)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('部署',style: TextStyle(fontStyle:FontStyle.normal)),
            onTap: () => Navigator.pop(context, 'Department'),
          ),
          ListTile(
            title: Text('グループ',style: TextStyle(fontStyle:FontStyle.normal)),
            onTap: () => Navigator.pop(context, 'Group'),
          ),
          ListTile(
            title: Text('チーム',style: TextStyle(fontStyle:FontStyle.normal)),
            onTap: () => Navigator.pop(context, 'Team'),
          ),
          ListTile(
            title: Text('社員',style: TextStyle(fontStyle:FontStyle.normal)),
            onTap: () => Navigator.pop(context, 'Employee'),
          ),
        ],)
    );
  }
}

List<Department> parseDepartments(List<List<dynamic>> fields) {
  return fields.skip(1).map((field) => Department(field[0] as int, field[1] as String)).toList();
}

List<Group> parseGroups(List<List<dynamic>> fields) {
  return fields.skip(1).map((field) => Group(field[0] as int, field[1] as String, field[2] as int)).toList();
}

List<Team> parseTeams(List<List<dynamic>> fields) {
  return fields.skip(1).map((field) => Team(field[0] as int, field[1] as String, field[2] as int)).toList();
}

List<Employee> parseEmployees(List<List<dynamic>> fields) {
  return fields.skip(1).map((field) => Employee(
    field[0] as int, field[1] as String, field[2] as String, field[3] as String, field[4] as String,
    departmentId: field[5] as int?, groupId: field[6] as int?, teamId: field[7] as int?, isHide: field[8] == 1 ? true : false
  )).toList();
}

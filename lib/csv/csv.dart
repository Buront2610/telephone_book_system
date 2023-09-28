import 'package:flutter/material.dart';
import '../db/db.dart';

bool isInt(String? s) {
  if (s == null) return false;
  return int.tryParse(s) != null;
}

//CSVデータの判定処理
String? validateCsvData(List<List<dynamic>> fields, String selectedTable) {
  if (fields.isEmpty) return "データが空です";

  List<dynamic> header = fields.first.map((e) => e.toString().trim()).toList();
  debugPrint("Header elements:");
  for (var element in header) {
    debugPrint("Element: [$element]");
  }
  debugPrint(fields.toString());
  debugPrint(selectedTable);

  switch (selectedTable) {
    case 'Department':
      if (!header.contains('id') || !header.contains('name')) {
        debugPrint('Incorrect header');
        return "ヘッダーが不足しています";
      }
      for (var row in fields.sublist(1)) {
        if (row.length != header.length) {
          debugPrint('Inconsistent row size');
          return "行のサイズが一致しません";
        }
        // Inconsistent row size
        if (row[0] == null || row[1] == null) {
          debugPrint('Null values');
          return "空にならないデータが空になっています";
        } // Null values
        if (!isInt(row[0]) || row[1] is! String) {
          debugPrint('Incorrect types');
          return "データの型が一致しません";
        } // Incorrect types
      }
      break;
    case 'Group':
      if (!header.contains('id') ||
          !header.contains('name') ||
          !header.contains('department_id')) {
        debugPrint('Incorrect header for Group');
        return "ヘッダーが不足しています";
      }
      for (var row in fields.sublist(1)) {
        if (row.length != header.length) {
          debugPrint('Inconsistent row size in Group');
          return "行のサイズが一致しません";
        }
        if (row[0] == null || row[1] == null || row[2] == null) {
          debugPrint('Null values in Group');
          return "空にならないデータが空になっています";
        }
        if (!isInt(row[0]) || row[1] is! String || !isInt(row[2])) {
          debugPrint('Incorrect types in Group');
          return "データの型が一致しません";
        }
      }
      break;
    case 'Team':
      if (!header.contains('id') ||
          !header.contains('name') ||
          !header.contains('group_id')) {
        debugPrint('Incorrect header for Team');
        return "ヘッダーが不足しています";
      }
      for (var row in fields.sublist(1)) {
        if (row.length != header.length) {
          debugPrint('Inconsistent row size in Team');
          return "行のサイズが一致しません";
        }
        if (row[0] == null || row[1] == null || row[2] == null) {
          debugPrint('Null values in Team');
          return "空にならないデータが空になっています";
        }
        if (!isInt(row[0]) || row[1] is! String || !isInt(row[2])) {
          debugPrint('Incorrect types in Team');
          return "データの型が一致しません";
        }
      }
      break;
    case 'Employee':
      List<String> requiredFields = [
        'id',
        'name',
        'email',
        'position',
        'extension',
        'department_ids',
        'group_ids',
        'team_ids',
        'is_hide'
      ];

      // Ensure each element in header is a String
      List<String> headerStrings = header.map((e) => e.toString()).toList();

      if (!Set<String>.from(headerStrings).containsAll(requiredFields)) {
        debugPrint('Incorrect header for Employee');
        return "ヘッダーが不足しています";
      }

      for (var row in fields.sublist(1)) {
        if (row.length != header.length) {
          debugPrint('Inconsistent row size');
          return "行のサイズが一致しません";
        }

        Map<String, dynamic> rowMap = Map.fromIterables(headerStrings, row);

        if (rowMap.values.any((element) => element == null)) {
          debugPrint('Null values');
          return "空にならないデータが空になっています";
        }

        if (!isInt(rowMap['id']) ||
            rowMap['name'] is! String ||
            rowMap['email'] is! String ||
            rowMap['position'] is! String ||
            rowMap['extension'] is! String) {
          debugPrint('Incorrect types');
          return "データの型が一致しません";
        }

        for (String field in ['department_ids', 'group_ids', 'team_ids']) {
          if (rowMap[field] is String) {
            var ids = rowMap[field].split(',');
            if (ids.any((id) => !isInt(id))) {
              debugPrint('Incorrect types in $field');
              return "$fieldのデータ型が一致しません";
            }
          }
        }
      }
      break;
  }
  return null;
}

List<List<dynamic>> validateAndTransformCsvData(
    List<List<dynamic>> fields, String selectedTable) {
  if (fields.isEmpty) return [];

  List<dynamic> header = fields.first.map((e) => e.toString().trim()).toList();
  debugPrint("Header elements:");
  for (var element in header) {
    debugPrint("Element: [$element]");
  }

  List<List<dynamic>> transformedFields = [];

  switch (selectedTable) {
    case 'Department':
      for (var row in fields.sublist(1)) {
        if (!isInt(row[0]) || row[1] is! String) {
          debugPrint('Incorrect types');
          return [];
        }
        transformedFields.add([int.parse(row[0]), row[1]]);
      }
      break;

    case 'Group':
      for (var row in fields.sublist(1)) {
        if (!isInt(row[0]) || row[1] is! String || !isInt(row[2])) {
          debugPrint('Incorrect types');
          return [];
        }
        transformedFields.add([int.parse(row[0]), row[1], int.parse(row[2])]);
      }
      break;

    case 'Team':
      for (var row in fields.sublist(1)) {
        if (!isInt(row[0]) || row[1] is! String || !isInt(row[2])) {
          debugPrint('Incorrect types');
          return [];
        }
        transformedFields.add([int.parse(row[0]), row[1], int.parse(row[2])]);
      }
      break;

    case 'Employee':
      for (var row in fields.sublist(1)) {
        if (!isInt(row[0]) ||
            row[1] is! String ||
            row[2] is! String ||
            row[3] is! String ||
            row[4] is! String) {
          debugPrint('Incorrect types');
          return [];
        }
        transformedFields.add([
          int.parse(row[0]),
          row[1],
          row[2],
          row[3],
          row[4],
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
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('データ編集項目を選択してください',
            style: TextStyle(fontStyle: FontStyle.normal)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('部署', style: TextStyle(fontStyle: FontStyle.normal)),
              onTap: () => Navigator.pop(context, 'Department'),
            ),
            ListTile(
              title:
                  Text('グループ', style: TextStyle(fontStyle: FontStyle.normal)),
              onTap: () => Navigator.pop(context, 'Group'),
            ),
            ListTile(
              title: Text('チーム', style: TextStyle(fontStyle: FontStyle.normal)),
              onTap: () => Navigator.pop(context, 'Team'),
            ),
            ListTile(
              title: Text('社員', style: TextStyle(fontStyle: FontStyle.normal)),
              onTap: () => Navigator.pop(context, 'Employee'),
            ),
          ],
        ));
  }
}

List<Department> parseDepartments(List<List<dynamic>> fields) {
  return fields
      .map((field) => Department(field[0] as int, field[1] as String))
      .toList();
}

List<Group> parseGroups(List<List<dynamic>> fields) {
  return fields
      .map((field) =>
          Group(field[0] as int, field[1] as String, field[2] as int))
      .toList();
}

List<Team> parseTeams(List<List<dynamic>> fields) {
  return fields
      .map(
          (field) => Team(field[0] as int, field[1] as String, field[2] as int))
      .toList();
}

List<Employee> parseEmployees(List<List<dynamic>> fields) {
  return fields.map((field) {
    List<int>? parseIds(String? ids) {
      if (ids == null || ids.isEmpty) return null;
      return ids
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((id) => int.parse(id))
          .toList();
    }

    return Employee(field[0] as int, field[1] as String, field[2] as String,
        field[3] as String, field[4] as String,
        departmentIds: parseIds(field[5] as String?),
        groupIds: parseIds(field[6] as String?),
        teamIds: parseIds(field[7] as String?),
        isHide: field[8] == 1 ? true : false);
  }).toList();
}

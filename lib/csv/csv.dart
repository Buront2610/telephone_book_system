bool validateCsvData(List<List<dynamic>> fields, String selectedTable) {
  if (fields.isEmpty) return false; // Empty CSV

  List<dynamic> header = fields.first;

  switch (selectedTable) {
    case 'Department':
      if (!header.contains('id') || !header.contains('name')) return false;
      for (var row in fields.sublist(1)) {
        if (row.length != header.length) return false; // Inconsistent row size
        if (row[0] == null || row[1] == null) return false; // Null values
        if (row[0] is! int || row[1] is! String) return false; // Incorrect types
      }
      break;
    case 'Group':
      // Similar checks for Group
      break;
    case 'Team':
      // Similar checks for Team
      break;
    case 'Employee':
      // Similar checks for Employee
      break;
  }
  return true;
}

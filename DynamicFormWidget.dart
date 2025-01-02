// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DynamicFormWidget extends StatefulWidget {
  const DynamicFormWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  Future<List<Map<String, dynamic>>>? formFields;

  @override
  void initState() {
    super.initState();
    formFields = DatabaseHelper.instance.fetchFormFields();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: formFields,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final fields = snapshot.data!;
          return Form(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index];
                final fieldName = field['Champs_Jotform'];
                final fieldType = field['Type_de_champs_Nb_Txt'];

                if (fieldType == 'Txt') {
                  return TextFormField(
                    decoration: InputDecoration(labelText: fieldName),
                  );
                } else if (fieldType == 'Nb') {
                  return TextFormField(
                    decoration: InputDecoration(labelText: fieldName),
                    keyboardType: TextInputType.number,
                  );
                } else if (fieldType == 'Radio') {
                  return Column(
                    children: [
                      Text(fieldName),
                      RadioListTile(
                        title: Text('Option 1'),
                        value: 'Option 1',
                        groupValue: fieldName,
                        onChanged: (value) {
                          setState(() {
                            // Update the state with the new value
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Option 2'),
                        value: 'Option 2',
                        groupValue: fieldName,
                        onChanged: (value) {
                          setState(() {
                            // Update the state with the new value
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('myApp.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, fileName);

      // Vérifiez si la base de données existe
      bool exists = await databaseExists(path);

      if (!exists) {
        // Si ce n'est pas le cas, copiez-la depuis les assets
        print('Database does not exist. Copying from assets.');
        ByteData data = await rootBundle.load(join('assets', fileName));
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes);
        print('Database copied from assets.');
      } else {
        print('Database already exists.');
      }

      return await openDatabase(path);
    } catch (e) {
      print('Error in _initDB: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchFormFields() async {
    try {
      final db = await instance.database;
      final result = await db.query(
          'FormFields'); // Assurez-vous que le nom de votre table est correct
      print('Fetched form fields: $result');
      return result;
    } catch (e) {
      print('Error in fetchFormFields: $e');
      rethrow;
    }
  }
}

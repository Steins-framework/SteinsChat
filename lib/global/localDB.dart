import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDB{
  static Future<Database> database;

  static init() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'local.db'),
      onCreate: (db, version) {
        return db.execute(_userTableSql());
      },
      version: 3,
    );
  }

  static String _userTableSql(){
    return '''CREATE TABLE "main"."users" (
  "id" INTEGER(255) NOT NULL,
  "name" text(255) NOT NULL,
  "avatar" TEXT(255),
  "status" integer(5) NOT NULL DEFAULT 1,
  "created_at" integer(255) NOT NULL,
  PRIMARY KEY ("id")
);''';
  }
}
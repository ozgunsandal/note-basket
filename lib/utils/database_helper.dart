import 'dart:io';

import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/models/notlar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper = null;
  static Database? _database = null;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }
  DatabaseHelper._internal();

  Future<Database?> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  Future<Database?> _initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "notlarKopya.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notlar.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    return await openDatabase(path, readOnly: false);
  }

  Future<List<Map<String, dynamic>>> kategorileriGetir() async {
    var db = await _getDatabase();
    var sonuc = await db!.query("kategori");
    return sonuc;
  }

  Future<List<Kategori>> kategoriListesiniGetir() async {
    var kategorileriIcerenMapListesi = await kategorileriGetir();
    var kategoriListesi = <Kategori>[];
    for (Map<String, dynamic> map in kategorileriIcerenMapListesi) {
      kategoriListesi.add(Kategori.fromMap(map));
    }
    return kategoriListesi;
  }

  Future<int> kategoriEkle(Kategori kategori) async {
    var db = await _getDatabase();
    var sonuc = await db!.insert('kategori', kategori.toMap());
    return sonuc;
  }

  Future<int> kategoriGuncelle(Kategori kategori) async {
    var db = await _getDatabase();
    var sonuc = await db!.update('kategori', kategori.toMap(),
        where: 'kategoriID = ?', whereArgs: [kategori.kategoriID]);
    return sonuc;
  }

  Future<int> kategoriSil(int kategoriID) async {
    var db = await _getDatabase();
    var sonuc = await db!
        .delete('kategori', where: 'kategoriID = ?', whereArgs: [kategoriID]);
    return sonuc;
  }

  Future<List<Map<String, dynamic>>> notlariGetir() async {
    var db = await _getDatabase();
    //var sonuc = await db!.query("not", orderBy: 'notID DESC');
    var sonuc = await db!.rawQuery(
        'select * from "not" inner join kategori on kategori.kategoriID = "not".kategoriID order by notID Desc'); //Kendi Sql sorgumuzu yazmak için rawquery kullandık.
    return sonuc;
  }

  Future<List<Not>> notListesiniGetir() async {
    var notlarMapListesi = await notlariGetir();
    var notListesi = <Not>[];
    for (Map<String, dynamic> map in notlarMapListesi) {
      notListesi.add(Not.fromMap(map));
    }
    return notListesi;
  }

  Future<int> notEkle(Not not) async {
    var db = await _getDatabase();
    var sonuc = await db!.insert('not', not.toMap());
    return sonuc;
  }

  Future<int> notGuncelle(Not not) async {
    var db = await _getDatabase();
    var sonuc = await db!
        .update('not', not.toMap(), where: 'notID = ?', whereArgs: [not.notID]);
    return sonuc;
  }

  Future<int> notSil(int notID) async {
    var db = await _getDatabase();
    var sonuc = await db!.delete('not', where: 'notID = ?', whereArgs: [notID]);
    return sonuc;
  }

  String dateFormat(DateTime dt) {
    DateTime today = DateTime.now();
    Duration oneDay = Duration(days: 1);
    Duration twoDay = Duration(days: 2);
    Duration oneWeek = Duration(days: 7);
    String? month;
    switch (dt.month) {
      case 1:
        month = 'ocak';
        break;
      case 2:
        month = 'şubat';
        break;
      case 3:
        month = 'mart';
        break;
      case 4:
        month = 'nisan';
        break;
      case 5:
        month = 'mayıs';
        break;
      case 6:
        month = 'haziran';
        break;
      case 7:
        month = 'temmuz';
        break;
      case 8:
        month = 'ağustos';
        break;
      case 9:
        month = 'eylül';
        break;
      case 10:
        month = 'ekim';
        break;
      case 11:
        month = 'kasım';
        break;
      case 12:
        month = 'aralık';
        break;
    }
    Duration difference = today.difference(dt);
    if (difference.compareTo(oneDay) < 1) {
      return 'bugün';
    } else if (difference.compareTo(twoDay) < 1) {
      return 'dün';
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (dt.weekday) {
        case 1:
          return 'pazartesi';
        case 2:
          return 'salı';
        case 3:
          return 'çarşamba';
        case 4:
          return 'perşembe';
        case 5:
          return 'cuma';
        case 6:
          return 'cumartesi';
        case 7:
          return 'pazar';
      }
    } else if (dt.year == today.year) {
      return '${dt.day} $month';
    } else {
      return '${dt.day} $month ${dt.year}';
    }
    return '';
  }
}

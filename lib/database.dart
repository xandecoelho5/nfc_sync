import 'dart:async';
import 'package:floor/floor.dart';
import 'package:nfc_sync/dao/quote_dao.dart';
import 'package:nfc_sync/models/quote.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database(version: 1, entities: [Quote])
abstract class AppDatabase extends FloorDatabase {
  QuoteDao get quoteDao;
}
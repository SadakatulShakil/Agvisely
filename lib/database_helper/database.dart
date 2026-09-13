import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

import 'dao/record_dao.dart';
import 'dao/cache_dao.dart';

import 'entity/record_entity.dart';
import 'entity/cache_entity.dart';

part 'database.g.dart';

// Version 2 accommodates the new CacheEntity
@Database(version: 2, entities: [RecordEntity, CacheEntity])
abstract class AppDatabase extends FloorDatabase {
  RecordDao get recordDao;
  CacheDao get cacheDao;
}
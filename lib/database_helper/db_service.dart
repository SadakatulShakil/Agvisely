import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper/database.dart';
import 'dao/cache_dao.dart';

class DBService extends GetxService {
  late AppDatabase _database;

  CacheDao get cacheDao => _database.cacheDao;

  Future<DBService> init() async {
    try {
      debugPrint('DEBUG: Starting database initialization...');

      _database = await $FloorAppDatabase
          .databaseBuilder('offline_agvisely.db')
          .build()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Database initialization timed out');
      });

      debugPrint('DEBUG: Database initialized successfully');
      return this;
    } catch (e) {
      debugPrint('🔥 DATABASE INIT FAILED: $e');
      try {
        await deleteDatabase('offline_agvisely.db');
        debugPrint('DEBUG: Deleted corrupt database, retrying...');
        _database = await $FloorAppDatabase
            .databaseBuilder('offline_agvisely.db')
            .build();
        debugPrint('DEBUG: Database recreated successfully');
        return this;
      } catch (e2) {
        debugPrint('🔥 DATABASE RECREATION FAILED: $e2');
        rethrow;
      }
    }
  }
}
import 'package:floor/floor.dart';
import '../entity/cache_entity.dart';

@dao
abstract class CacheDao {
  @Query('SELECT * FROM cache_table WHERE cacheKey = :key')
  Future<CacheEntity?> getCache(String key);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertCache(CacheEntity cache);

  @Query('DELETE FROM cache_table')
  Future<void> clearAllCache();
}
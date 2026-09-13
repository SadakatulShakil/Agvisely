import 'package:floor/floor.dart';

@Entity(tableName: 'cache_table')
class CacheEntity {
  @primaryKey
  final String cacheKey;

  final String jsonData;
  final int timestamp;

  CacheEntity(this.cacheKey, this.jsonData, this.timestamp);
}
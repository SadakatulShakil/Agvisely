import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One row of assets/json/location_list.json — a single union, carrying its
/// upazila/district/division. The dataset is a flat list of 5063 unions.
class UnionRecord {
  final String name;
  final String nameBn;
  final String pcode;
  final double lat;
  final double lng;
  final String upazila;
  final String upazilaBn;
  final String upazilaCode;
  final String district;
  final String districtBn;
  final String districtCode;
  final String division;
  final String divisionCode;
  final String thana;
  final String thanaBn;

  UnionRecord({
    required this.name,
    required this.nameBn,
    required this.pcode,
    required this.lat,
    required this.lng,
    required this.upazila,
    required this.upazilaBn,
    required this.upazilaCode,
    required this.district,
    required this.districtBn,
    required this.districtCode,
    required this.division,
    required this.divisionCode,
    required this.thana,
    required this.thanaBn,
  });

  factory UnionRecord.fromJson(Map<String, dynamic> json) => UnionRecord(
    name: json['name'] ?? '',
    nameBn: json['name_bn'] ?? '',
    pcode: json['pcode'] ?? '',
    lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
    lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    upazila: json['upazila'] ?? '',
    upazilaBn: json['upazila_bn'] ?? '',
    upazilaCode: json['upazila_code'] ?? '',
    district: json['district'] ?? '',
    districtBn: json['district_bn'] ?? '',
    districtCode: json['district_code'] ?? '',
    division: json['division'] ?? '',
    divisionCode: json['division_code'] ?? '',
    thana: json['thana'] ?? '',
    thanaBn: json['thana_bn'] ?? '',
  );
}

/// A district or upazila entry deduped from the flat union list, carrying
/// both display languages.
class NamedArea {
  final String name;
  final String nameBn;
  final String code;

  const NamedArea({required this.name, required this.nameBn, required this.code});
}

class LocationRepository {
  static List<UnionRecord>? _cache;

  Future<List<UnionRecord>> _loadAll() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString('assets/json/location_list.json');
      final Map<String, dynamic> decoded = json.decode(raw);
      final List<dynamic> list = decoded['data'] ?? [];
      _cache = list.map((e) => UnionRecord.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error loading location_list.json: $e');
      _cache = [];
    }
    return _cache!;
  }

  Future<List<NamedArea>> districts() async {
    final all = await _loadAll();
    final seen = <String, NamedArea>{};
    for (final u in all) {
      seen.putIfAbsent(
        u.districtCode,
        () => NamedArea(name: u.district, nameBn: u.districtBn, code: u.districtCode),
      );
    }
    final result = seen.values.toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  Future<List<NamedArea>> upazilasOf(String districtCode) async {
    final all = await _loadAll();
    final seen = <String, NamedArea>{};
    for (final u in all.where((e) => e.districtCode == districtCode)) {
      seen.putIfAbsent(
        u.upazilaCode,
        () => NamedArea(name: u.upazila, nameBn: u.upazilaBn, code: u.upazilaCode),
      );
    }
    final result = seen.values.toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  Future<List<UnionRecord>> unionsOf(String districtCode, String upazilaCode) async {
    final all = await _loadAll();
    final result = all
        .where((e) => e.districtCode == districtCode && e.upazilaCode == upazilaCode)
        .toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  /// Case-insensitive search across name/name_bn/upazila/upazila_bn/district/district_bn.
  Future<List<UnionRecord>> search(String query) async {
    final all = await _loadAll();
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.nameBn.toLowerCase().contains(q) ||
          u.upazila.toLowerCase().contains(q) ||
          u.upazilaBn.toLowerCase().contains(q) ||
          u.district.toLowerCase().contains(q) ||
          u.districtBn.toLowerCase().contains(q);
    }).toList();
  }

  /// Nearest union to (lat, lng) by great-circle (haversine) distance.
  Future<UnionRecord?> nearest(double lat, double lng) async {
    final all = await _loadAll();
    if (all.isEmpty) return null;

    UnionRecord? closest;
    double closestDistance = double.infinity;
    for (final u in all) {
      final d = _haversineKm(lat, lng, u.lat, u.lng);
      if (d < closestDistance) {
        closestDistance = d;
        closest = u;
      }
    }
    return closest;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@lazySingleton
class HiveManager {
  static const String _moviesBox = 'movies_cache';
  static const String _settingsBox = 'user_settings';
  static const String _favoritesBox = 'favorite_movies';

  Box<dynamic>? _moviesBoxInstance;
  Box<dynamic>? _favoritesBoxInstance;

  bool _isInitialized = false;
  Timer? _cleanupTimer;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        Hive.init('');
      } else {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      }

      await _preOpenBoxes();
      _startPeriodicCleanup();

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('HiveManager initialization failed: $e');
      }
      rethrow;
    }
  }

  Future<void> _preOpenBoxes() async {
    _moviesBoxInstance = await Hive.openBox(_moviesBox);
    _favoritesBoxInstance = await Hive.openBox(_favoritesBox);
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 6), (timer) {
      _cleanupExpiredCache();
    });
  }

  Future<void> _cleanupExpiredCache() async {
    if (!_isInitialized) return;

    try {
      final moviesBox = _moviesBoxInstance ?? await Hive.openBox(_moviesBox);
      final keysToDelete = <String>[];

      for (final key in moviesBox.keys) {
        final value = moviesBox.get(key);
        if (value is Map<String, dynamic> && value.containsKey('expiry')) {
          final expiry = value['expiry'] as int?;
          final timestamp = value['timestamp'] as int?;

          if (expiry != null && timestamp != null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - timestamp > expiry) {
              keysToDelete.add(key.toString());
            }
          }
        }
      }

      for (final key in keysToDelete) {
        await moviesBox.delete(key);
      }

      if (kDebugMode && keysToDelete.isNotEmpty) {
        print('Cleaned up ${keysToDelete.length} expired movie cache items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache cleanup failed: $e');
      }
    }
  }

  Future<Box<T>> _getBox<T>(String boxName) async {
    if (!_isInitialized) await initialize();

    switch (boxName) {
      case _moviesBox:
        return (_moviesBoxInstance ??= await Hive.openBox<T>(boxName))
            as Box<T>;
      case _favoritesBox:
        return (_favoritesBoxInstance ??= await Hive.openBox<T>(boxName))
            as Box<T>;
      default:
        return await Hive.openBox<T>(boxName);
    }
  }

  // Movie Cache Operations
  Future<void> cacheMovieData(
    String key,
    dynamic value, {
    Duration? expiry,
  }) async {
    final box = await _getBox(_moviesBox);
    final cacheItem = {
      'data': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry':
          expiry?.inMilliseconds ?? const Duration(hours: 24).inMilliseconds,
    };
    await box.put(key, cacheItem);
  }

  Future<T?> getCachedMovieData<T>(String key) async {
    final box = await _getBox(_moviesBox);
    final cacheItem = box.get(key) as Map<String, dynamic>?;

    if (cacheItem == null) return null;

    final timestamp = cacheItem['timestamp'] as int;
    final expiry = cacheItem['expiry'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - timestamp > expiry) {
      await box.delete(key);
      return null;
    }

    return cacheItem['data'] as T?;
  }

  Future<void> clearMovieCache() async {
    final box = await _getBox(_moviesBox);
    await box.clear();
  }

  // Settings Operations
  Future<void> saveSetting(String key, dynamic value) async {
    final box = await _getBox(_settingsBox);
    await box.put(key, value);
  }

  Future<T?> getSetting<T>(String key) async {
    final box = await _getBox(_settingsBox);
    return box.get(key) as T?;
  }

  Future<Map<String, dynamic>> getAllSettings() async {
    final box = await _getBox(_settingsBox);
    return Map<String, dynamic>.from(box.toMap());
  }

  // Favorites Operations
  Future<void> addToFavorites(
    int movieId,
    Map<String, dynamic> movieData,
  ) async {
    final box = await _getBox(_favoritesBox);
    await box.put(movieId.toString(), movieData);
  }

  Future<void> removeFromFavorites(int movieId) async {
    final box = await _getBox(_favoritesBox);
    await box.delete(movieId.toString());
  }

  Future<bool> isFavorite(int movieId) async {
    final box = await _getBox(_favoritesBox);
    return box.containsKey(movieId.toString());
  }

  Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final box = await _getBox(_favoritesBox);
    return box.values.map((value) {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return <String, dynamic>{};
    }).toList();
  }

  // Utility Operations
  Future<void> storeJsonData(
    String key,
    Map<String, dynamic> data, {
    Duration? expiry,
  }) async {
    final jsonString = jsonEncode(data);
    await cacheMovieData(key, jsonString, expiry: expiry);
  }

  Future<Map<String, dynamic>?> getJsonData(String key) async {
    final jsonString = await getCachedMovieData<String>(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to decode JSON for key $key: $e');
        }
        return null;
      }
    }
    return null;
  }

  Future<void> clearAllData() async {
    if (!_isInitialized) return;

    try {
      await Future.wait([
        _clearBox(_moviesBox),
        _clearBox(_settingsBox),
        _clearBox(_favoritesBox),
      ]);

      _cleanupTimer?.cancel();

      if (kDebugMode) {
        print('All movie app data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear all data: $e');
      }
      rethrow;
    }
  }

  Future<void> clearFavorites() async {
    if (!_isInitialized) return;

    try {
      await _clearBox(_favoritesBox);
      if (kDebugMode) {
        print('Favorites data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear favorites: $e');
      }
      rethrow;
    }
  }

  Future<void> _clearBox(String boxName) async {
    try {
      final box = await _getBox(boxName);
      await box.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear box $boxName: $e');
      }
    }
  }

  Future<void> dispose() async {
    _cleanupTimer?.cancel();

    await Future.wait([
      _moviesBoxInstance?.close() ?? Future.value(),
      _favoritesBoxInstance?.close() ?? Future.value(),
    ]);

    _isInitialized = false;

    if (kDebugMode) {
      print('HiveManager disposed');
    }
  }

  bool get isInitialized => _isInitialized;
}

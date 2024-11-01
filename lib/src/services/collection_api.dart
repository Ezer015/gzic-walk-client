import 'package:shared_preferences/shared_preferences.dart';

enum CollectionProperty {
  discovery,
  favorite,
}

class CollectionApi {
  static final CollectionApi _instance = CollectionApi._();

  factory CollectionApi() => _instance;

  CollectionApi._();

  static Future<void> init() async {
    _instance._prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  late final SharedPreferencesWithCache _prefsWithCache;

  static String transformKey(CollectionProperty property) => switch (property) {
        CollectionProperty.discovery => 'discovery_id_',
        CollectionProperty.favorite => 'favorite_ids',
      };

  static Future<void> setBool(
    String key,
    bool value,
  ) async =>
      await _instance._prefsWithCache.setBool(key, value);
  static Future<void> setDouble(
    String key,
    double value,
  ) async =>
      await _instance._prefsWithCache.setDouble(key, value);
  static Future<void> setInt(
    String key,
    int value,
  ) async =>
      await _instance._prefsWithCache.setInt(key, value);
  static Future<void> setString(
    String key,
    String value,
  ) async =>
      await _instance._prefsWithCache.setString(key, value);
  static Future<void> setStringList(
    String key,
    List<String> value,
  ) async =>
      await _instance._prefsWithCache.setStringList(key, value);

  static bool? getBool(String key) => _instance._prefsWithCache.getBool(key);
  static double? getDouble(String key) =>
      _instance._prefsWithCache.getDouble(key);
  static int? getInt(String key) => _instance._prefsWithCache.getInt(key);
  static String? getString(String key) =>
      _instance._prefsWithCache.getString(key);
  static List<String>? getStringList(String key) =>
      _instance._prefsWithCache.getStringList(key);

  static bool containsKey(String key) =>
      _instance._prefsWithCache.containsKey(key);
  static Future<void> remove(String key) async =>
      await _instance._prefsWithCache.remove(key);

  static Future<void> Function(int) idAdder(CollectionProperty property) =>
      (int id) async => await setStringList(
            transformKey(property),
            (getStringList(transformKey(property)) ?? [])..add(id.toString()),
          );
  static Future<void> addFavorite(int recordID) async =>
      await idAdder(CollectionProperty.favorite)(recordID);

  static Future<void> addDiscovery({
    required int sightID,
    required int recordID,
  }) async =>
      await setInt(
        '${transformKey(CollectionProperty.discovery)}$sightID',
        recordID,
      );

  static Future<void> Function(int) idRemover(CollectionProperty property) =>
      (int id) async => await setStringList(
            transformKey(property),
            (getStringList(transformKey(property)) ?? [])
              ..remove(id.toString()),
          );
  static Future<void> removeFavorite(int recordID) async =>
      await idRemover(CollectionProperty.favorite)(recordID);

  static Future<void> removeDiscovery(int sightID) async =>
      await remove('${transformKey(CollectionProperty.discovery)}$sightID');

  static List<int>? Function() idGetter(CollectionProperty property) => () {
        final idStrs = getStringList(transformKey(property));
        if (idStrs == null) {
          return null;
        }

        final parsedIDs = <int>[];
        for (String idStr in idStrs) {
          final id = int.tryParse(idStr);
          if (id != null) {
            parsedIDs.add(id);
          }
        }

        return parsedIDs;
      };
  static List<int>? get favoriteIDs => idGetter(CollectionProperty.favorite)();

  static int? getDiscovery(int sightID) =>
      getInt('${transformKey(CollectionProperty.discovery)}$sightID');

  static bool isFavorite(int recordID) =>
      (favoriteIDs ?? []).contains(recordID);
}

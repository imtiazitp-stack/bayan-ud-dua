import 'package:shared_preferences/shared_preferences.dart';

/// Stores favorited dua ids on-device (no account/login needed).
/// Uses Dua.appId (an int) so it survives any future re-ordering
/// of the book content without breaking a user's saved favorites.
class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  static const _key = 'favorite_dua_ids';
  Set<int> _favorites = {};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    _favorites = list.map(int.parse).toSet();
    _loaded = true;
  }

  Future<Set<int>> getAll() async {
    await _ensureLoaded();
    return _favorites;
  }

  Future<bool> isFavorite(int appId) async {
    await _ensureLoaded();
    return _favorites.contains(appId);
  }

  Future<void> toggle(int appId) async {
    await _ensureLoaded();
    if (_favorites.contains(appId)) {
      _favorites.remove(appId);
    } else {
      _favorites.add(appId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _favorites.map((e) => e.toString()).toList(),
    );
  }
}

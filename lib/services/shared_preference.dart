import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _key = "search_history";

  /// Save a new search query
  static Future<void> saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing history or empty list
    List<String> history = prefs.getStringList(_key) ?? [];

    // Remove if already exists (to avoid duplicates)
    history.remove(query);

    // Add query at the start
    history.insert(0, query);

    // Limit history to last 10 items
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await prefs.setStringList(_key, history);
  }

  /// Get all saved searches
  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Clear all search history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

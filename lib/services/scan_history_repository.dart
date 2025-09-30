import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nfc_scan_result.dart';

class ScanHistoryRepository {
  static const String _historyKey = 'nfc_scan_history';
  static const int _maxHistoryItems = 100;

  Future<List<NFCScanResult>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      return historyJson
          .map((json) => NFCScanResult.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      return [];
    }
  }

  Future<void> addToHistory(NFCScanResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      // Thêm kết quả mới vào đầu danh sách
      history.insert(0, result);

      // Giới hạn số lượng lịch sử
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      // Lưu lại
      final historyJson = history
          .map((item) => jsonEncode(item.toJson()))
          .toList();

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      // Bỏ qua lỗi khi lưu
    }
  }

  Future<void> deleteItem(DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      history.removeWhere((item) => item.timestamp == timestamp);

      final historyJson = history
          .map((item) => jsonEncode(item.toJson()))
          .toList();

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      // Bỏ qua lỗi
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      // Bỏ qua lỗi
    }
  }

  Future<NFCScanResult?> getLatestScan() async {
    final history = await getHistory();
    return history.isNotEmpty ? history.first : null;
  }

  Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }

  Future<List<NFCScanResult>> searchHistory(String query) async {
    final history = await getHistory();

    if (query.isEmpty) return history;

    return history.where((item) {
      return item.id.toLowerCase().contains(query.toLowerCase()) ||
          item.type.toLowerCase().contains(query.toLowerCase()) ||
          item.data.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<NFCScanResult>> getHistoryByType(String type) async {
    final history = await getHistory();
    return history.where((item) => item.type == type).toList();
  }

  Future<List<NFCScanResult>> getHistoryByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final history = await getHistory();
    return history.where((item) {
      return item.timestamp.isAfter(start) && item.timestamp.isBefore(end);
    }).toList();
  }
}

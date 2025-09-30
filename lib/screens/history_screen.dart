import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/scan_history_repository.dart';
import '../models/nfc_scan_result.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScanHistoryRepository _repository = ScanHistoryRepository();
  List<NFCScanResult> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _repository.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(NFCScanResult item) async {
    await _repository.deleteItem(item.timestamp);
    _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa khỏi lịch sử')));
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử quét?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.clearHistory();
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa toàn bộ lịch sử')));
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã sao chép vào clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử quét'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearHistory,
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lịch sử quét',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColorForType(item.type),
                      child: Icon(
                        _getIconForType(item.type),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      item.data.length > 30
                          ? '${item.data.substring(0, 30)}...'
                          : item.data,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('ID: ${item.id}'),
                        Text('Loại: ${item.type}'),
                        Text(
                          _formatDateTime(item.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () => _copyToClipboard(item.data),
                          child: const Row(
                            children: [
                              Icon(Icons.copy, size: 20),
                              SizedBox(width: 8),
                              Text('Sao chép'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () => _deleteItem(item),
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showDetailDialog(item),
                  ),
                );
              },
            ),
    );
  }

  void _showDetailDialog(NFCScanResult item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', item.id),
              _buildDetailRow('Loại', item.type),
              _buildDetailRow('Dữ liệu', item.data),
              _buildDetailRow('Thời gian', _formatDateTime(item.timestamp)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          FilledButton.icon(
            onPressed: () {
              _copyToClipboard(item.data);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Sao chép'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return Colors.blue;
      case 'url':
        return Colors.green;
      case 'unknown':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return Icons.text_fields;
      case 'url':
        return Icons.link;
      case 'unknown':
        return Icons.help_outline;
      default:
        return Icons.nfc;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

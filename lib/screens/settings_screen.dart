import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSaveHistory = true;
  bool _vibrateOnScan = true;
  bool _soundOnScan = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSaveHistory = prefs.getBool('auto_save_history') ?? true;
      _vibrateOnScan = prefs.getBool('vibrate_on_scan') ?? true;
      _soundOnScan = prefs.getBool('sound_on_scan') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Quét NFC',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Tự động lưu lịch sử'),
                  subtitle: const Text('Lưu tất cả các lần quét vào lịch sử'),
                  value: _autoSaveHistory,
                  onChanged: (value) {
                    setState(() => _autoSaveHistory = value);
                    _saveSetting('auto_save_history', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Rung khi quét'),
                  subtitle: const Text('Rung khi quét thành công'),
                  value: _vibrateOnScan,
                  onChanged: (value) {
                    setState(() => _vibrateOnScan = value);
                    _saveSetting('vibrate_on_scan', value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Âm thanh khi quét'),
                  subtitle: const Text('Phát âm thanh khi quét thành công'),
                  value: _soundOnScan,
                  onChanged: (value) {
                    setState(() => _soundOnScan = value);
                    _saveSetting('sound_on_scan', value);
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Về ứng dụng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Phiên bản'),
                  subtitle: const Text('0.1.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Giới thiệu'),
                  subtitle: const Text('Ứng dụng đọc, ghi, xóa thẻ NFC'),
                  onTap: () => _showAboutDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Hướng dẫn sử dụng'),
                  onTap: () => _showHelpDialog(),
                ),
              ],
            ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về NFC App'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NFC App v0.1.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Ứng dụng quản lý thẻ NFC với đầy đủ tính năng:'),
              SizedBox(height: 8),
              Text('• Đọc thẻ NFC'),
              Text('• Ghi dữ liệu lên thẻ'),
              Text('• Xóa dữ liệu trên thẻ'),
              Text('• Lưu lịch sử quét'),
              SizedBox(height: 16),
              Text(
                'Được phát triển với Flutter',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hướng dẫn sử dụng'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Đọc thẻ NFC:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Nhấn nút "Đọc NFC"'),
              Text('2. Đặt thẻ NFC gần thiết bị'),
              Text('3. Chờ quá trình đọc hoàn tất'),
              SizedBox(height: 16),
              Text(
                'Ghi dữ liệu:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Nhấn nút "Ghi NFC"'),
              Text('2. Nhập nội dung cần ghi'),
              Text('3. Đặt thẻ NFC gần thiết bị'),
              SizedBox(height: 16),
              Text(
                'Xóa dữ liệu:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Nhấn nút "Xóa NFC"'),
              Text('2. Xác nhận xóa'),
              Text('3. Đặt thẻ NFC gần thiết bị'),
              SizedBox(height: 16),
              Text(
                'Lưu ý:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text('• Giữ thẻ gần thiết bị trong khi quét'),
              Text('• Không di chuyển thẻ trong quá trình ghi/xóa'),
              Text('• Một số thẻ có thể được bảo vệ ghi'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.nfc, color: Colors.blue, size: 30),
            ),
            const SizedBox(width: 12),
            const Text('NFC App'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Phiên bản 0.1.0',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                '📱 Ứng dụng quản lý thẻ NFC toàn diện',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem('✅', 'Đọc thông tin thẻ NFC'),
              _buildFeatureItem('✏️', 'Ghi dữ liệu Text và URL'),
              _buildFeatureItem('🎵', 'Ghi link nhạc lên thẻ NFC'),
              _buildFeatureItem('🗑️', 'Xóa dữ liệu trên thẻ'),
              _buildFeatureItem('📜', 'Lưu lịch sử quét thẻ'),
              _buildFeatureItem('🔍', 'Tìm kiếm bài hát'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 Công nghệ:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Flutter Framework'),
                    Text('• flutter_nfc_kit'),
                    Text('• NDEF Protocol'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '© 2024 NFC App\nPhát triển với ❤️ bằng Flutter',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
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

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📖 Hướng dẫn sử dụng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                icon: Icons.nfc,
                title: '1️⃣ Tab NFC (Trang chủ)',
                steps: [
                  '• Đọc thẻ NFC: Nhấn "Đọc NFC" → Đặt thẻ lên',
                  '• Ghi Text: Nhấn "Ghi NFC" → Chọn "Ghi Text" → Nhập nội dung → Đặt thẻ',
                  '• Ghi URL: Nhấn "Ghi NFC" → Chọn "Ghi URI" → Nhập link → Đặt thẻ',
                  '• Ghi URL nhạc: Chọn bài trong tab Music trước → Quay lại → Nhấn "Ghi NFC" → Chọn "Ghi URL nhạc"',
                  '• Xóa: Nhấn "Xóa NFC" → Xác nhận → Đặt thẻ',
                ],
              ),
              const Divider(),
              _buildHelpSection(
                icon: Icons.music_note,
                title: '2️⃣ Tab Music',
                steps: [
                  '• Tìm kiếm bài hát theo tên hoặc ca sĩ',
                  '• Nhấn vào bài hát để chọn (chỉ chọn được 1 bài)',
                  '• Bài đã chọn sẽ hiển thị ở card phía trên',
                  '• Quay lại tab NFC để ghi URL nhạc lên thẻ',
                  '• Nhấn nút X để bỏ chọn bài hát',
                ],
              ),
              const Divider(),
              _buildHelpSection(
                icon: Icons.history,
                title: '3️⃣ Tab Lịch sử',
                steps: [
                  '• Xem tất cả lần đọc/ghi thẻ NFC',
                  '• Nhấn vào item để xem chi tiết',
                  '• Sao chép dữ liệu vào clipboard',
                  '• Xóa từng item hoặc xóa tất cả',
                ],
              ),
              const Divider(),
              _buildHelpSection(
                icon: Icons.settings,
                title: '4️⃣ Tab Cài đặt',
                steps: [
                  '• Bật/tắt tự động lưu lịch sử',
                  '• Bật/tắt rung khi quét',
                  '• Bật/tắt âm thanh',
                  '• Xem thông tin ứng dụng',
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '⚠️ Lưu ý quan trọng:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Giữ thẻ NFC sát thiết bị khi quét'),
                    Text('• KHÔNG di chuyển thẻ trong lúc ghi/xóa'),
                    Text('• Một số thẻ có thể bị khóa ghi'),
                    Text('• Thẻ MIFARE Classic cần authentication'),
                    Text('• iPhone chỉ ghi được thẻ NDEF'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Mẹo hay:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Ghi URL Spotify/YouTube để tạo thẻ nhạc'),
                    Text('• Ghi link WiFi để chia sẻ mật khẩu'),
                    Text('• Ghi vCard để chia sẻ danh bạ'),
                    Text('• Ghi link website cho marketing'),
                  ],
                ),
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

  Widget _buildHelpSection({
    required IconData icon,
    required String title,
    required List<String> steps,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(left: 32, top: 4),
            child: Text(step, style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

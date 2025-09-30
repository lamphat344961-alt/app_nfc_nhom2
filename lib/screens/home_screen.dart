import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../services/nfc_service.dart';
import '../services/selected_music_service.dart';
import '../models/nfc_scan_result.dart';
import '../widgets/nfc_scan_button.dart';
import '../widgets/nfc_animation_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NFCService _nfcService = NFCService();
  final SelectedMusicService _selectedMusicService = SelectedMusicService();
  bool _isNFCAvailable = false;
  bool _isScanning = false;
  NFCScanResult? _lastScanResult;
  String _statusMessage = 'Sẵn sàng';

  @override
  void initState() {
    super.initState();
    _checkNFCAvailability();
  }

  Future<void> _checkNFCAvailability() async {
    final avail = await FlutterNfcKit.nfcAvailability;
    final isAvailable = avail == NFCAvailability.available;
    setState(() {
      _isNFCAvailable = isAvailable;
      _statusMessage = isAvailable
          ? 'NFC khả dụng ✅'
          : 'Thiết bị không hỗ trợ NFC ❌';
    });
  }

  Future<void> _startNFCRead() async {
    if (!_isNFCAvailable) return;

    setState(() {
      _isScanning = true;
      _statusMessage = 'Đang quét... Đặt thẻ NFC lên';
    });

    try {
      final result = await _nfcService.readNFC();
      setState(() {
        _lastScanResult = result;
        _statusMessage = 'Đọc thành công! ✅';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _startNFCWrite() async {
    if (!_isNFCAvailable) return;

    // Kiểm tra xem có bài nhạc được chọn không
    final selectedMusic = _selectedMusicService.selectedMusic;
    String? initialText;
    String? initialType;

    if (selectedMusic != null) {
      // Nếu có bài nhạc được chọn, hỏi xem có muốn ghi URL nhạc không
      final useMusic = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ghi dữ liệu NFC'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bạn đã chọn bài nhạc:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedMusic.thumbnail ?? '🎵',
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedMusic.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            selectedMusic.artist,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bạn muốn ghi gì lên thẻ NFC?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nhập tùy chỉnh'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ghi URL nhạc'),
            ),
          ],
        ),
      );

      if (useMusic == null) return;

      if (useMusic == true) {
        // Ghi trực tiếp URL nhạc
        initialText = selectedMusic.url;
        initialType = 'uri';
      }
    }

    // Nếu không có nhạc hoặc chọn nhập tùy chỉnh
    if (initialText == null) {
      final controller = TextEditingController();
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ghi dữ liệu NFC'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nhập nội dung',
                  hintText: 'Ví dụ: Hello NFC hoặc https://example.com',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              const Text(
                'Chọn loại dữ liệu:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, {
                'text': controller.text,
                'type': 'text',
              }),
              child: const Text('Ghi Text'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, {
                'text': controller.text,
                'type': 'uri',
              }),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Ghi URI'),
            ),
          ],
        ),
      );

      if (result == null || result['text']?.isEmpty == true) return;
      initialText = result['text'];
      initialType = result['type'];
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Đang ghi... Đặt thẻ NFC lên';
    });

    try {
      if (initialType == 'uri') {
        await _nfcService.writeNFCUri(initialText!);
      } else {
        await _nfcService.writeNFCText(initialText!);
      }

      setState(() {
        _statusMessage = 'Ghi thành công! ✅';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ghi dữ liệu thành công!')),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi ghi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _startNFCErase() async {
    if (!_isNFCAvailable) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dữ liệu NFC'),
        content: const Text(
          'Bạn có chắc muốn xóa dữ liệu trên thẻ NFC?\n\n'
          'Lưu ý: Thao tác này sẽ ghi text rỗng lên thẻ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isScanning = true;
      _statusMessage = 'Đang xóa... Đặt thẻ NFC lên';
    });

    try {
      await _nfcService.eraseNFC();
      setState(() {
        _statusMessage = 'Xóa thành công! ✅';
        _lastScanResult = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa dữ liệu thành công!')),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi xóa: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMusic = _selectedMusicService.selectedMusic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Đọc/Ghi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkNFCAvailability,
            tooltip: 'Kiểm tra lại NFC',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Hiển thị bài nhạc đã chọn (nếu có)
                      if (selectedMusic != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Text(
                                selectedMusic.thumbnail ?? '🎵',
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bài nhạc đã chọn:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      selectedMusic.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      selectedMusic.artist,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      NFCAnimationIcon(isScanning: _isScanning),
                      const SizedBox(height: 32),
                      Text(
                        _statusMessage,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      if (_lastScanResult != null) ...[
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Kết quả quét',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                const Divider(),
                                _buildInfoRow('ID:', _lastScanResult!.id),
                                _buildInfoRow('Loại:', _lastScanResult!.type),
                                _buildInfoRow(
                                  'Standard:',
                                  _lastScanResult!.standard,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Dữ liệu NDEF:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _lastScanResult!.data.isEmpty
                                        ? '(Không có dữ liệu)'
                                        : _lastScanResult!.data,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (_isNFCAvailable) ...[
                NFCScanButton(
                  label: 'Đọc NFC',
                  icon: Icons.nfc,
                  onPressed: _isScanning ? null : _startNFCRead,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                NFCScanButton(
                  label: selectedMusic != null
                      ? 'Ghi NFC (có bài nhạc)'
                      : 'Ghi NFC',
                  icon: Icons.edit,
                  onPressed: _isScanning ? null : _startNFCWrite,
                  color: selectedMusic != null ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 12),
                NFCScanButton(
                  label: 'Xóa NFC',
                  icon: Icons.delete_outline,
                  onPressed: _isScanning ? null : _startNFCErase,
                  color: Colors.red,
                ),
              ] else
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'NFC không khả dụng trên thiết bị này',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}

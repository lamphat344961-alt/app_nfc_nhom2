import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import '../models/nfc_scan_result.dart';
import 'scan_history_repository.dart';

class NFCService {
  final ScanHistoryRepository _repository = ScanHistoryRepository();

  /// Đọc thẻ NFC
  Future<NFCScanResult> readNFC() async {
    try {
      // Poll thẻ NFC
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 15),
      );

      // Lấy thông tin cơ bản của thẻ
      String id = tag.id ?? 'Unknown';
      String type = tag.type?.toString() ?? 'Unknown';
      String standard = tag.standard?.toString() ?? 'Unknown';
      String ndefData = '';

      // Đọc NDEF records
      try {
        final records = await FlutterNfcKit.readNDEFRecords();

        if (records.isEmpty) {
          ndefData = '(Không có NDEF record)';
        } else {
          for (var i = 0; i < records.length; i++) {
            final record = records[i];
            ndefData += 'Record ${i + 1}:\n';

            // Phân tích từng loại record
            if (record is ndef.TextRecord) {
              ndefData += '  Type: Text\n';
              ndefData += '  Text: ${record.text}\n';
              ndefData += '  Language: ${record.language}\n';
            } else if (record is ndef.UriRecord) {
              ndefData += '  Type: URI\n';
              ndefData += '  URI: ${record.uri}\n';
            } else if (record is ndef.MimeRecord) {
              ndefData += '  Type: MIME\n';
              ndefData += '  MIME Type: ${record.decodedType}\n';
            } else {
              ndefData += '  Type: ${record.decodedType}\n';
              ndefData += '  Data: ${record.payload}\n';
            }
            ndefData += '\n';
          }
        }
      } catch (e) {
        ndefData = '(Thẻ không hỗ trợ NDEF hoặc chưa format)\nError: $e';
      }

      // Tạo kết quả
      final result = NFCScanResult(
        id: id,
        type: type,
        standard: standard,
        data: ndefData,
        timestamp: DateTime.now(),
      );

      // Lưu vào lịch sử
      await _repository.addToHistory(result);

      return result;
    } catch (e) {
      throw Exception('Lỗi khi đọc thẻ: $e');
    } finally {
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
    }
  }

  /// Ghi text lên thẻ NFC
  Future<void> writeNFCText(String text) async {
    try {
      // Poll thẻ
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 15),
      );

      // Tạo Text Record
      final record = ndef.TextRecord(
        text: text,
        language: 'en',
        encoding: ndef.TextEncoding.UTF8,
      );

      // Ghi lên thẻ
      await FlutterNfcKit.writeNDEFRecords([record]);

      // Lưu vào lịch sử
      await _repository.addToHistory(
        NFCScanResult(
          id: tag.id ?? 'Unknown',
          type: 'Write Text',
          standard: tag.standard?.toString() ?? 'Unknown',
          data: 'Đã ghi text: $text',
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('Lỗi khi ghi text: $e');
    } finally {
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
    }
  }

  /// Ghi URI lên thẻ NFC
  Future<void> writeNFCUri(String uri) async {
    try {
      // Poll thẻ
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 15),
      );

      // Tạo URI Record
      final record = ndef.UriRecord.fromString(uri);

      // Ghi lên thẻ
      await FlutterNfcKit.writeNDEFRecords([record]);

      // Lưu vào lịch sử
      await _repository.addToHistory(
        NFCScanResult(
          id: tag.id ?? 'Unknown',
          type: 'Write URI',
          standard: tag.standard?.toString() ?? 'Unknown',
          data: 'Đã ghi URI: $uri',
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('Lỗi khi ghi URI: $e');
    } finally {
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
    }
  }

  /// Xóa dữ liệu trên thẻ NFC (ghi text rỗng)
  Future<void> eraseNFC() async {
    try {
      // Poll thẻ
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 15),
      );

      // Tạo Text Record rỗng
      final emptyRecord = ndef.TextRecord(
        text: '',
        language: 'en',
        encoding: ndef.TextEncoding.UTF8,
      );

      // Ghi record rỗng
      await FlutterNfcKit.writeNDEFRecords([emptyRecord]);

      // Lưu vào lịch sử
      await _repository.addToHistory(
        NFCScanResult(
          id: tag.id ?? 'Unknown',
          type: 'Erase',
          standard: tag.standard?.toString() ?? 'Unknown',
          data: 'Đã xóa dữ liệu (ghi text rỗng)',
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('Lỗi khi xóa: $e');
    } finally {
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
    }
  }

  /// Kiểm tra khả dụng NFC
  Future<bool> isNFCAvailable() async {
    final availability = await FlutterNfcKit.nfcAvailability;
    return availability == NFCAvailability.available;
  }
}

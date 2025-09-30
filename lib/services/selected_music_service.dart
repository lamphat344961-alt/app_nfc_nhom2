import '../models/music.dart';

/// Service để lưu bài nhạc đã chọn (dùng chung giữa các screen)
class SelectedMusicService {
  static final SelectedMusicService _instance =
      SelectedMusicService._internal();
  factory SelectedMusicService() => _instance;
  SelectedMusicService._internal();

  Music? _selectedMusic;

  // Lấy bài nhạc đã chọn
  Music? get selectedMusic => _selectedMusic;

  // Lấy URL của bài nhạc đã chọn
  String? get selectedMusicUrl => _selectedMusic?.url;

  // Set bài nhạc đã chọn
  void setSelectedMusic(Music? music) {
    _selectedMusic = music;
  }

  // Xóa bài nhạc đã chọn
  void clearSelection() {
    _selectedMusic = null;
  }

  // Kiểm tra có bài nhạc nào được chọn không
  bool get hasSelection => _selectedMusic != null;
}

import 'package:flutter/material.dart';
import '../models/music.dart';
import '../services/music_repository.dart';
import '../services/selected_music_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final SelectedMusicService _selectedMusicService = SelectedMusicService();
  List<Music> _musicList = [];
  List<Music> _filteredList = [];
  Music? _selectedMusic;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMusic();
    // Load bài hát đã chọn trước đó (nếu có)
    _selectedMusic = _selectedMusicService.selectedMusic;
  }

  void _loadMusic() {
    setState(() {
      _musicList = MusicRepository.getMusicList();
      _filteredList = _musicList;

      // Đánh dấu bài hát đã chọn
      if (_selectedMusic != null) {
        for (var m in _musicList) {
          m.isSelected = (m.id == _selectedMusic!.id);
        }
      }
    });
  }

  void _onMusicSelected(Music music) {
    setState(() {
      // Bỏ chọn tất cả
      for (var m in _musicList) {
        m.isSelected = false;
      }
      // Chọn bài hiện tại
      music.isSelected = true;
      _selectedMusic = music;

      // Lưu vào service để HomeScreen có thể dùng
      _selectedMusicService.setSelectedMusic(music);
    });

    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chọn: ${music.title}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onSearch(String query) {
    setState(() {
      _filteredList = MusicRepository.searchMusic(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách nhạc'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài hát, ca sĩ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Hiển thị bài hát đã chọn
          if (_selectedMusic != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedMusic!.thumbnail ?? '🎵',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đã chọn:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedMusic!.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _selectedMusic!.artist,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedMusic!.isSelected = false;
                        _selectedMusic = null;
                        _selectedMusicService.clearSelection();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã bỏ chọn')),
                      );
                    },
                  ),
                ],
              ),
            ),

          // Music list
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy bài hát',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final music = _filteredList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        color: music.isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: music.isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            child: Text(
                              music.thumbnail ?? '🎵',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          title: Text(
                            music.title,
                            style: TextStyle(
                              fontWeight: music.isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(music.artist),
                          trailing: music.isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : const Icon(Icons.radio_button_unchecked),
                          onTap: () => _onMusicSelected(music),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

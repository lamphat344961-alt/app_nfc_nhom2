import '../models/music.dart';

class MusicRepository {
  // Danh sách nhạc mẫu (có thể thay bằng API thực tế)
  static List<Music> getMusicList() {
    return [
      Music(
        id: '1',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        url: 'https://open.spotify.com/track/0VjIjW4GlUZAMYd2vXMi3b',
        thumbnail: '🎵',
      ),
      Music(
        id: '2',
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        url: 'https://open.spotify.com/track/7qiZfU4dY1lWllzX7mPBI',
        thumbnail: '🎵',
      ),
      Music(
        id: '3',
        title: 'Someone Like You',
        artist: 'Adele',
        url: 'https://open.spotify.com/track/1zwMYTA5nlNjZxYrvBB2pV',
        thumbnail: '🎵',
      ),
      Music(
        id: '4',
        title: 'Despacito',
        artist: 'Luis Fonsi ft. Daddy Yankee',
        url: 'https://www.youtube.com/watch?v=kJQP7kiw5Fk',
        thumbnail: '🎵',
      ),
      Music(
        id: '5',
        title: 'Bohemian Rhapsody',
        artist: 'Queen',
        url: 'https://www.youtube.com/watch?v=fJ9rUzIMcZQ',
        thumbnail: '🎵',
      ),
      Music(
        id: '6',
        title: 'Perfect',
        artist: 'Ed Sheeran',
        url: 'https://open.spotify.com/track/0tgVpDi06FyKpA1z0VMD4v',
        thumbnail: '🎵',
      ),
      Music(
        id: '7',
        title: 'Thinking Out Loud',
        artist: 'Ed Sheeran',
        url: 'https://open.spotify.com/track/4ThxGxxmJthljWDqMb4r7m',
        thumbnail: '🎵',
      ),
      Music(
        id: '8',
        title: 'Uptown Funk',
        artist: 'Mark Ronson ft. Bruno Mars',
        url: 'https://www.youtube.com/watch?v=OPf0YbXqDm0',
        thumbnail: '🎵',
      ),
      Music(
        id: '9',
        title: 'Counting Stars',
        artist: 'OneRepublic',
        url: 'https://www.youtube.com/watch?v=hT_nvWreIhg',
        thumbnail: '🎵',
      ),
      Music(
        id: '10',
        title: 'Hello',
        artist: 'Adele',
        url: 'https://open.spotify.com/track/4aebBr4JAihzJQR0CiIZJv',
        thumbnail: '🎵',
      ),
      Music(
        id: '11',
        title: 'Senorita',
        artist: 'Shawn Mendes & Camila Cabello',
        url: 'https://open.spotify.com/track/6v3KW9xbzN5yKLt9YKDYA2',
        thumbnail: '🎵',
      ),
      Music(
        id: '12',
        title: 'Levitating',
        artist: 'Dua Lipa',
        url: 'https://open.spotify.com/track/463CkQjx2Zk1yXoBuierM9',
        thumbnail: '🎵',
      ),
      Music(
        id: '13',
        title: 'Bad Guy',
        artist: 'Billie Eilish',
        url: 'https://open.spotify.com/track/2Fxmhks0bxGSBdJ92vM42m',
        thumbnail: '🎵',
      ),
      Music(
        id: '14',
        title: 'Believer',
        artist: 'Imagine Dragons',
        url: 'https://www.youtube.com/watch?v=7wtfhZwyrcc',
        thumbnail: '🎵',
      ),
      Music(
        id: '15',
        title: 'Rolling in the Deep',
        artist: 'Adele',
        url: 'https://www.youtube.com/watch?v=rYEDA3JcQqw',
        thumbnail: '🎵',
      ),
    ];
  }

  // Lọc theo từ khóa
  static List<Music> searchMusic(String query) {
    if (query.isEmpty) return getMusicList();

    final lowerQuery = query.toLowerCase();
    return getMusicList().where((music) {
      return music.title.toLowerCase().contains(lowerQuery) ||
          music.artist.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Lấy nhạc đã chọn
  static Music? getSelectedMusic(List<Music> musicList) {
    try {
      return musicList.firstWhere((music) => music.isSelected);
    } catch (e) {
      return null;
    }
  }
}

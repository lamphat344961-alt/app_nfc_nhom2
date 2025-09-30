class Music {
  final String id;
  final String title;
  final String artist;
  final String url;
  final String? thumbnail;
  bool isSelected;

  Music({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    this.thumbnail,
    this.isSelected = false,
  });

  Music copyWith({
    String? id,
    String? title,
    String? artist,
    String? url,
    String? thumbnail,
    bool? isSelected,
  }) {
    return Music(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'thumbnail': thumbnail,
      'isSelected': isSelected,
    };
  }

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }
}

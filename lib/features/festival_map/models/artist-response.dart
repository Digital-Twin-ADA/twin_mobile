class ArtistResponse {
  final int id;
  final String name;
  final String genre;
  final String bio;
  final String country;
  final String? imageUrl;

  const ArtistResponse({
    required this.id,
    required this.name,
    required this.genre,
    required this.bio,
    required this.country,
    required this.imageUrl,
  });

  factory ArtistResponse.fromJson(Map<String, dynamic> json) {
    return ArtistResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      genre: json['genre'] as String,
      bio: json['bio'] as String,
      country: json['country'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
class CharacterLocation {
  final String name;
  final String url;

  CharacterLocation({required this.name, required this.url});

  factory CharacterLocation.fromJson(Map<String, dynamic> json) {
    return CharacterLocation(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final CharacterLocation origin;
  final CharacterLocation location;
  final String image;
  final List<String> episode;
  final String url;
  final String created;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episode,
    required this.url,
    required this.created,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String,
      gender: json['gender'] as String,
      origin: CharacterLocation.fromJson(
          json['origin'] as Map<String, dynamic>),
      location: CharacterLocation.fromJson(
          json['location'] as Map<String, dynamic>),
      image: json['image'] as String,
      episode: (json['episode'] as List<dynamic>).cast<String>(),
      url: json['url'] as String,
      created: json['created'] as String,
    );
  }
}

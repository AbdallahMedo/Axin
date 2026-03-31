class Room {
  final String id;
  final String name;
  final String? floorId;
  final String? picture;

  Room({required this.id, required this.name, this.floorId, this.picture});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['area_id'],
      name: json['name'],
      floorId: json['floor_id'],
      picture: json['picture'],
    );
  }
}

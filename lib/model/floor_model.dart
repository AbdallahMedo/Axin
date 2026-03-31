class Floor {
  final String floorId;
  final String name;
  final int? level;

  Floor({required this.floorId, required this.name, this.level});

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      floorId: json['floor_id'],
      name: json['name'],
      level: json['level'],
    );
  }
}

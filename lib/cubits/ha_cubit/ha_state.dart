import '../../model/entity_model.dart';

abstract class HAState {}

class HAInitial extends HAState {}

class HALoading extends HAState {}

class HALoaded extends HAState {
  final String locationName;
  final List<Map<String, dynamic>> floors;
  final List<Map<String, dynamic>> rooms;
  final Map<String, String> entityToRoom;
  final List<EntityModel> entities;
  final Map<String, int> devicesStats;

  HALoaded({
    required this.locationName,
    required this.floors,
    required this.rooms,
    required this.entityToRoom,
    required this.entities,
    required this.devicesStats,
  });

  HALoaded copyWith({
    String? locationName,
    List<Map<String, dynamic>>? floors,
    List<Map<String, dynamic>>? rooms,
    Map<String, String>? entityToRoom,
    List<EntityModel>? entities,
    Map<String, int>? devicesStats,
  }) {
    return HALoaded(
      locationName: locationName ?? this.locationName,
      floors: floors ?? this.floors,
      rooms: rooms ?? this.rooms,
      entityToRoom: entityToRoom ?? this.entityToRoom,
      entities: entities ?? this.entities,
      devicesStats: devicesStats ?? this.devicesStats,
    );
  }
}

class HAError extends HAState {
  final String message;
  HAError(this.message);
}
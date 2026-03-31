class EntityModel {
  final String entityId;
  final String state; // 'on' or 'off'
  final String friendlyName;
  final String? icon;
  final String? areaId;

  EntityModel({
    required this.entityId,
    required this.state,
    required this.friendlyName,
    this.icon,
    this.areaId,
  });

  bool get isOn => state == 'on';

  factory EntityModel.fromJson(Map<String, dynamic> json) {
    return EntityModel(
      entityId: json['entity_id'],
      state: json['state'],
      friendlyName: json['attributes']['friendly_name'] ?? json['entity_id'],
      icon: json['attributes']['icon'],
      areaId: json['area_id'], // This might not be in the states API directly
    );
  }

  EntityModel copyWith({String? state, String? areaId}) {
    return EntityModel(
      entityId: entityId,
      state: state ?? this.state,
      friendlyName: friendlyName,
      icon: icon,
      areaId: areaId ?? this.areaId,
    );
  }
}

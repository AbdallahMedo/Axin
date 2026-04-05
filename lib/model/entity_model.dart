class EntityModel {
  final String entityId;
  final String state;
  final String friendlyName;
  final String? icon;
  final String? areaId;
  final Map<String, dynamic> attributes;

  EntityModel({
    required this.entityId,
    required this.state,
    required this.friendlyName,
    this.icon,
    this.areaId,
    this.attributes = const {},
  });

  // input_boolean → on/off
  // input_number  → state is the numeric value as string
  // input_select  → state is the selected option
  bool get isOn {
    if (entityId.startsWith('input_boolean.')) return state == 'on';
    if (entityId.startsWith('input_number.')) {
      // treat as "on" when value > 0
      final v = double.tryParse(state);
      return v != null && v > 0;
    }
    if (entityId.startsWith('input_select.')) {
      // treat as "on" when not 'off' / 'none' / 'unknown'
      return state != 'off' && state != 'none' && state != 'unknown' && state != 'unavailable';
    }
    return state == 'on';
  }

  DeviceType get deviceType {
    if (entityId.startsWith('light.')) return DeviceType.light;
    if (entityId.startsWith('fan.')) return DeviceType.fan;
    if (entityId.startsWith('cover.')) return DeviceType.cover;
    if (entityId.startsWith('climate.')) return DeviceType.climate;
    if (entityId.startsWith('media_player.')) return DeviceType.mediaPlayer;
    if (entityId.startsWith('lock.')) return DeviceType.lock;
    if (entityId.startsWith('vacuum.')) return DeviceType.vacuum;
    if (entityId.startsWith('switch.')) return DeviceType.switch_;
    if (entityId.startsWith('input_boolean.')) return DeviceType.inputBoolean;
    // ── NEW ──
    if (entityId.startsWith('input_number.')) return DeviceType.inputNumber;
    if (entityId.startsWith('input_select.')) return DeviceType.inputSelect;
    return DeviceType.switch_;
  }

  // ── light brightness (0-255) ──
  int get brightness {
    if (entityId.startsWith('input_number.')) {
      // For input_number used as a light dimmer the state IS the value
      final v = double.tryParse(state);
      if (v != null) return v.toInt();
    }
    if (attributes.containsKey('brightness')) {
      return (attributes['brightness'] as num).toInt();
    }
    return 0;
  }

  // ── input_number: raw numeric value ──
  double get inputNumberValue {
    final v = double.tryParse(state);
    return v ?? 0.0;
  }

  double get inputNumberMin {
    if (attributes.containsKey('min')) return (attributes['min'] as num).toDouble();
    return 0.0;
  }

  double get inputNumberMax {
    if (attributes.containsKey('max')) return (attributes['max'] as num).toDouble();
    return 100.0;
  }

  double get inputNumberStep {
    if (attributes.containsKey('step')) return (attributes['step'] as num).toDouble();
    return 1.0;
  }

  String get inputNumberUnit {
    return attributes['unit_of_measurement'] as String? ?? '';
  }

  // ── input_select: current option + available options ──
  String get inputSelectOption => state;

  List<String> get inputSelectOptions {
    final opts = attributes['options'];
    if (opts is List) return opts.cast<String>();
    return [];
  }

  // ── fan speed ──
  String get fanSpeed {
    if (entityId.startsWith('input_select.')) return state;
    return attributes['speed'] as String? ?? 'off';
  }

  // ── cover position ──
  int get coverPosition {
    if (attributes.containsKey('current_position')) {
      return (attributes['current_position'] as num).toInt();
    }
    return 0;
  }

  // ── climate ──
  double get temperature {
    if (attributes.containsKey('temperature')) {
      return (attributes['temperature'] as num).toDouble();
    }
    return 22.0;
  }

  String get hvacMode {
    return attributes['hvac_mode'] as String? ?? 'off';
  }

  factory EntityModel.fromJson(Map<String, dynamic> json) {
    return EntityModel(
      entityId: json['entity_id'],
      state: json['state'],
      friendlyName: json['attributes']['friendly_name'] ?? json['entity_id'],
      icon: json['attributes']['icon'],
      areaId: json['area_id'],
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
    );
  }

  EntityModel copyWith({
    String? state,
    String? areaId,
    Map<String, dynamic>? attributes,
  }) {
    return EntityModel(
      entityId: entityId,
      state: state ?? this.state,
      friendlyName: friendlyName,
      icon: icon,
      areaId: areaId ?? this.areaId,
      attributes: attributes ?? this.attributes,
    );
  }
}

enum DeviceType {
  light,
  fan,
  cover,
  climate,
  mediaPlayer,
  lock,
  vacuum,
  switch_,
  inputBoolean,
  inputNumber, // ← NEW
  inputSelect, // ← NEW
}
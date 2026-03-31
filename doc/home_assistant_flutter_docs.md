# Home Assistant API — Flutter Documentation

## معلومات الاتصال

```
Base URL: http://192.168.1.5:8123
Token:    Bearer <YOUR_LONG_LIVED_TOKEN>
```

---

## 1. إعداد المشروع

### pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.2
```

---

## 2. API Service Class

```dart
// lib/services/ha_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class HAService {
  final String baseUrl = 'http://192.168.1.5:8123';
  final String token = 'YOUR_LONG_LIVED_TOKEN_HERE';

  Map<String, String> get headers => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // ✅ تحقق إن السيرفر شغال
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ✅ جيب كل الـ Floors
  Future<List<dynamic>> getFloors() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/config/floor_registry'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load floors');
  }

  // ✅ جيب كل الـ Rooms (Areas)
  Future<List<dynamic>> getRooms() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/config/area_registry'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load rooms');
  }

  // ✅ جيب كل الـ Entities
  Future<List<dynamic>> getAllEntities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/states'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load entities');
  }

  // ✅ جيب حالة entity معينة
  Future<Map<String, dynamic>> getEntityState(String entityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/states/$entityId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get state for $entityId');
  }

  // ✅ شغّل اللمبة
  Future<void> turnOn(String entityId) async {
    await http.post(
      Uri.parse('$baseUrl/api/services/input_boolean/turn_on'),
      headers: headers,
      body: jsonEncode({'entity_id': entityId}),
    );
  }

  // ✅ طفي اللمبة
  Future<void> turnOff(String entityId) async {
    await http.post(
      Uri.parse('$baseUrl/api/services/input_boolean/turn_off'),
      headers: headers,
      body: jsonEncode({'entity_id': entityId}),
    );
  }

  // ✅ Toggle (لو شغّالة تطفيها، لو مطفية تشغّلها)
  Future<void> toggle(String entityId) async {
    await http.post(
      Uri.parse('$baseUrl/api/services/input_boolean/toggle'),
      headers: headers,
      body: jsonEncode({'entity_id': entityId}),
    );
  }
}
```

---

## 3. Models

```dart
// lib/models/room.dart
class Room {
  final String id;
  final String name;
  final String? floorId;

  Room({required this.id, required this.name, this.floorId});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['area_id'],
      name: json['name'],
      floorId: json['floor_id'],
    );
  }
}

// lib/models/entity.dart
class Entity {
  final String entityId;
  final String state; // 'on' or 'off'
  final String friendlyName;
  final String? icon;

  Entity({
    required this.entityId,
    required this.state,
    required this.friendlyName,
    this.icon,
  });

  bool get isOn => state == 'on';

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      entityId: json['entity_id'],
      state: json['state'],
      friendlyName: json['attributes']['friendly_name'] ?? json['entity_id'],
      icon: json['attributes']['icon'],
    );
  }
}
```

---

## 4. مثال UI — شاشة Living Room

```dart
// lib/screens/room_screen.dart

import 'package:flutter/material.dart';
import '../services/ha_service.dart';
import '../models/entity.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final HAService _service = HAService();
  Entity? _light;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLight();
  }

  Future<void> _loadLight() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getEntityState(
        'input_boolean.living_room_light',
      );
      setState(() {
        _light = Entity.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleLight() async {
    if (_light == null) return;
    await _service.toggle(_light!.entityId);
    await _loadLight(); // refresh الحالة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Living Room')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb,
                    size: 80,
                    color: _light!.isOn ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _light!.friendlyName,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _light!.isOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 18,
                      color: _light!.isOn ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Switch(
                    value: _light!.isOn,
                    onChanged: (_) => _toggleLight(),
                  ),
                ],
              ),
            ),
    );
  }
}
```

---

## 5. API Endpoints Reference

| الغرض | Method | Endpoint |
|-------|--------|----------|
| التحقق من الاتصال | GET | `/api/` |
| كل الـ Entities | GET | `/api/states` |
| حالة entity معينة | GET | `/api/states/{entity_id}` |
| كل الـ Floors | GET | `/api/config/floor_registry` |
| كل الـ Rooms | GET | `/api/config/area_registry` |
| تشغيل | POST | `/api/services/input_boolean/turn_on` |
| إطفاء | POST | `/api/services/input_boolean/turn_off` |
| Toggle | POST | `/api/services/input_boolean/toggle` |

---

## 6. Entity IDs عندك

| الاسم | Entity ID | النوع |
|-------|-----------|-------|
| Living Room Light | `input_boolean.living_room_light` | Toggle |

---

## 7. ملاحظات مهمة

- **الـ Token**: لا تحطه في الكود مباشرة في production — استخدم `flutter_secure_storage`
- **الشبكة**: التطبيق والـ Raspberry Pi لازم يكونوا على نفس الـ WiFi
- **HTTPS**: لو هتنشر للإنترنت استخدم Home Assistant Cloud أو Nginx بشهادة SSL
- **لما يجي الهاردوير**: غيّر `input_boolean` بـ `light` في الـ service calls

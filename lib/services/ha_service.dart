// ha_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';

class HAWebSocketService {
  final String host = '192.168.1.5';
  final int port = 8123;
  final String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI5NDIyNjBiNGUwYzU0YWU2ODc2Njk4NzFiZjI4MDM0ZCIsImlhdCI6MTc3NDkwMDk1OSwiZXhwIjoyMDkwMjYwOTU5fQ.emSCOUoOPoxMjhQeqTNQ2Btd3iZteGdy0qQu0rs1bCY';

  late final Dio _dio;

  WebSocketChannel? _channel;
  int _msgId = 1;

  final StreamController<Map<String, dynamic>> _stateChangeController =
  StreamController.broadcast();
  final StreamController<List<dynamic>> _floorsController =
  StreamController.broadcast();
  final StreamController<List<dynamic>> _roomsController =
  StreamController.broadcast();
  final StreamController<List<dynamic>> _entityRegistryController =
  StreamController.broadcast();

  Stream<Map<String, dynamic>> get stateChanges =>
      _stateChangeController.stream;
  Stream<List<dynamic>> get floorsStream => _floorsController.stream;
  Stream<List<dynamic>> get roomsStream => _roomsController.stream;
  Stream<List<dynamic>> get entityRegistryStream =>
      _entityRegistryController.stream;

  int _floorsRequestId = 0;
  int _roomsRequestId = 0;
  int _entityRegistryRequestId = 0;

  HAWebSocketService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://$host:$port/api',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<List<Map<String, dynamic>>> getAllEntities() async {
    try {
      final response = await _dio.get('/states');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<String> getLocationName() async {
    try {
      final response = await _dio.get('/config');
      if (response.statusCode == 200) {
        return response.data['location_name'] ?? 'Smart Home';
      }
      return 'Smart Home';
    } catch (e) {
      return 'Smart Home';
    }
  }

  Future<void> toggle(String entityId) async {
    try {
      await _dio.post('/services/homeassistant/toggle', data: {
        'entity_id': entityId,
      });
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<Map<String, int>> getDevicesStats() async {
    try {
      final entities = await getAllEntities();

      int totalDevices = 0;
      int activeDevices = 0;
      int totalScenes = 0;
      int activeScenes = 0;
      int totalAutomations = 0;
      int activeAutomations = 0;

      for (var entity in entities) {
        final entityId = entity['entity_id'] as String;
        final state = entity['state'] as String;

        if (entityId.startsWith('switch.') ||
            entityId.startsWith('light.') ||
            entityId.startsWith('fan.') ||
            entityId.startsWith('cover.') ||
            entityId.startsWith('lock.') ||
            entityId.startsWith('media_player.') ||
            entityId.startsWith('climate.') ||
            entityId.startsWith('vacuum.') ||
            entityId.startsWith('input_boolean.')) {
          totalDevices++;
          if (state == 'on' ||
              state == 'playing' ||
              state == 'open' ||
              state == 'unlocked' ||
              state == 'home') {
            activeDevices++;
          }
        }

        if (entityId.startsWith('scene.')) {
          totalScenes++;
          if (state == 'on') activeScenes++;
        }

        if (entityId.startsWith('automation.')) {
          totalAutomations++;
          if (state == 'on') activeAutomations++;
        }
      }

      return {
        'totalDevices': totalDevices,
        'activeDevices': activeDevices,
        'totalScenes': totalScenes,
        'activeScenes': activeScenes,
        'totalAutomations': totalAutomations,
        'activeAutomations': activeAutomations,
      };
    } catch (e) {
      return {
        'totalDevices': 0,
        'activeDevices': 0,
        'totalScenes': 0,
        'activeScenes': 0,
        'totalAutomations': 0,
        'activeAutomations': 0,
      };
    }
  }

  void connect() {
    final uri = Uri.parse('ws://$host:$port/api/websocket');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
          (message) => _handleMessage(jsonDecode(message)),
      onDone: _reconnect,
      onError: (_) => _reconnect(),
    );
  }

  void _handleMessage(Map<String, dynamic> msg) {
    final type = msg['type'];

    if (type == 'auth_required') {
      _send({'type': 'auth', 'access_token': token});
    } else if (type == 'auth_ok') {
      _requestFloors();
      _requestRooms();
      _requestEntityRegistry();
      _subscribeToStateChanges();
      _subscribeToRegistryChanges(); // ✅ الجديد
    } else if (type == 'result') {
      final id = msg['id'] as int;
      final success = msg['success'] as bool? ?? false;
      if (!success) return;

      final result = msg['result'];
      if (id == _floorsRequestId && result is List) {
        _floorsController.add(result);
      } else if (id == _roomsRequestId && result is List) {
        _roomsController.add(result);
      } else if (id == _entityRegistryRequestId && result is List) {
        _entityRegistryController.add(result);
      }
    } else if (type == 'event') {
      final eventData = msg['event'];
      final eventType = eventData?['event_type'];

      if (eventType == 'state_changed') {
        // ✅ تحديث state الجهاز
        final newState = eventData['data']?['new_state'];
        if (newState != null) {
          _stateChangeController.add(newState);
        }
      } else if (eventType == 'floor_registry_updated') {
        // ✅ اسم الـ floor اتغير → اجيب الـ floors من جديد
        _requestFloors();
      } else if (eventType == 'area_registry_updated') {
        // ✅ اسم الـ room اتغير → اجيب الـ rooms من جديد
        _requestRooms();
      } else if (eventType == 'entity_registry_updated') {
        // ✅ اسم الجهاز اتغير → اجيب الـ entity registry من جديد
        _requestEntityRegistry();
      }
    }
  }

  void _requestFloors() {
    _floorsRequestId = _msgId;
    _send({'id': _msgId++, 'type': 'config/floor_registry/list'});
  }

  void _requestRooms() {
    _roomsRequestId = _msgId;
    _send({'id': _msgId++, 'type': 'config/area_registry/list'});
  }

  void _requestEntityRegistry() {
    _entityRegistryRequestId = _msgId;
    _send({'id': _msgId++, 'type': 'config/entity_registry/list'});
  }

  void _subscribeToStateChanges() {
    _send({
      'id': _msgId++,
      'type': 'subscribe_events',
      'event_type': 'state_changed',
    });
  }

  // ✅ الجديد: اشترك في تغييرات الـ registry
  void _subscribeToRegistryChanges() {
    _send({
      'id': _msgId++,
      'type': 'subscribe_events',
      'event_type': 'floor_registry_updated',
    });
    _send({
      'id': _msgId++,
      'type': 'subscribe_events',
      'event_type': 'area_registry_updated',
    });
    _send({
      'id': _msgId++,
      'type': 'subscribe_events',
      'event_type': 'entity_registry_updated',
    });
  }

  void _send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 3), connect);
  }

  void disconnect() {
    _channel?.sink.close();
    _stateChangeController.close();
    _floorsController.close();
    _roomsController.close();
    _entityRegistryController.close();
  }
}
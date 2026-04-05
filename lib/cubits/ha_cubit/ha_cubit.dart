// ha_cubit.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../services/ha_service.dart';
import '../../model/entity_model.dart';
import 'ha_state.dart';

class HACubit extends Cubit<HAState> {
  final HAWebSocketService _service;
  final HAWebSocketService _wsService;

  StreamSubscription? _stateChangeSub;
  StreamSubscription? _floorsSub;
  StreamSubscription? _roomsSub;
  StreamSubscription? _entityRegistrySub;

  List<Map<String, dynamic>> _floors = [];
  List<Map<String, dynamic>> _rooms = [];
  Map<String, String> _entityToRoom = {};
  List<EntityModel> _entities = [];
  String _locationName = 'Smart Home';
  Map<String, int> _devicesStats = {};

  HACubit(this._service, this._wsService) : super(HAInitial());

  Future<void> fetchData() async {
    emit(HALoading());
    try {
      final entitiesJson = await _service.getAllEntities();
      _locationName = await _service.getLocationName();
      _devicesStats = await _service.getDevicesStats();

      _entities = entitiesJson.map((e) => EntityModel.fromJson(e)).toList();

      try {
        final person =
        _entities.firstWhere((e) => e.entityId.startsWith('person.'));
        _locationName = person.friendlyName;
      } catch (_) {}

      _startWebSocket();
    } on DioException catch (e) {
      String msg = "Connection error";
      if (e.response?.statusCode == 401) msg = "Unauthorized (Invalid Token)";
      else if (e.type == DioExceptionType.connectionTimeout) msg = "Connection Timeout";
      else if (e.response?.statusCode != null) msg = "Server error: ${e.response?.statusCode}";
      emit(HAError(msg));
    } catch (e) {
      emit(HAError("Unexpected error: ${e.toString()}"));
    }
  }

  void _startWebSocket() {
    _floorsSub = _wsService.floorsStream.listen((data) {
      _floors = List<Map<String, dynamic>>.from(data);
      _tryEmitLoaded();
    });

    _roomsSub = _wsService.roomsStream.listen((data) {
      _rooms = List<Map<String, dynamic>>.from(data);
      _tryEmitLoaded();
    });

    _entityRegistrySub = _wsService.entityRegistryStream.listen((data) {
      _entityToRoom = {};
      for (var entry in data) {
        final entityId = entry['entity_id'] as String?;
        final areaId = entry['area_id'] as String?;
        if (entityId != null && areaId != null) {
          _entityToRoom[entityId] = areaId;
        }
      }
      _tryEmitLoaded();
    });

    _stateChangeSub = _wsService.stateChanges.listen((newState) {
      if (state is HALoaded) {
        final current = state as HALoaded;
        final entityId = newState['entity_id'] as String?;
        if (entityId == null) return;

        // ✅ حدّث الـ entities
        final updatedEntities = current.entities.map((e) {
          if (e.entityId == entityId) return EntityModel.fromJson(newState);
          return e;
        }).toList();

        // ✅ احسب الـ stats فوراً من الـ entities المحدثة
        final updatedStats = _calculateStats(updatedEntities);

        emit(current.copyWith(
          entities: updatedEntities,
          devicesStats: updatedStats,
        ));
      }
    });

    _wsService.connect();
  }

  void _tryEmitLoaded() {
    if (_floors.isNotEmpty && _rooms.isNotEmpty && _entityToRoom.isNotEmpty) {
      final updatedEntities = _entities.map((e) {
        return e.copyWith(areaId: _entityToRoom[e.entityId]);
      }).toList();

      emit(HALoaded(
        locationName: _locationName,
        floors: _floors,
        rooms: _rooms,
        entityToRoom: _entityToRoom,
        entities: updatedEntities,
        devicesStats: _devicesStats,
      ));
    }
  }

  // ✅ حساب الـ stats محلياً من غير REST call
  Map<String, int> _calculateStats(List<EntityModel> entities) {
    int totalDevices = 0, activeDevices = 0;
    int totalScenes = 0, activeScenes = 0;
    int totalAutomations = 0, activeAutomations = 0;

    for (var entity in entities) {
      final id = entity.entityId;
      final st = entity.state;

      if (id.startsWith('switch.') ||
          id.startsWith('light.') ||
          id.startsWith('fan.') ||
          id.startsWith('cover.') ||
          id.startsWith('lock.') ||
          id.startsWith('media_player.') ||
          id.startsWith('climate.') ||
          id.startsWith('vacuum.') ||
          id.startsWith('input_boolean.')) {
        totalDevices++;
        if (st == 'on' ||
            st == 'playing' ||
            st == 'open' ||
            st == 'unlocked' ||
            st == 'home') {
          activeDevices++;
        }
      }

      if (id.startsWith('scene.')) {
        totalScenes++;
        if (st == 'on') activeScenes++;
      }

      if (id.startsWith('automation.')) {
        totalAutomations++;
        if (st == 'on') activeAutomations++;
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
  }

  Future<void> toggleEntity(String entityId) async {
    try {
      await _service.toggle(entityId);
    } catch (e) {
      emit(HAError("Toggle failed: ${e.toString()}"));
    }
  }

  Future<void> refreshStats() async {
    try {
      _devicesStats = await _service.getDevicesStats();
      if (state is HALoaded) {
        final current = state as HALoaded;
        emit(current.copyWith(devicesStats: _devicesStats));
      }
    } catch (e) {}
  }
  Future<void> setBrightness(String entityId, int brightness) async {
    try {
      await _service.setBrightness(entityId, brightness);
    } catch (e) {
      emit(HAError("Failed to set brightness: ${e.toString()}"));
    }
  }

  Future<void> setFanSpeed(String entityId, String speed) async {
    try {
      await _service.setFanSpeed(entityId, speed);
    } catch (e) {
      emit(HAError("Failed to set fan speed: ${e.toString()}"));
    }
  }

  Future<void> setCoverPosition(String entityId, int position) async {
    try {
      await _service.setCoverPosition(entityId, position);
    } catch (e) {
      emit(HAError("Failed to set cover position: ${e.toString()}"));
    }
  }

  Future<void> setTemperature(String entityId, double temperature) async {
    try {
      await _service.setTemperature(entityId, temperature);
    } catch (e) {
      emit(HAError("Failed to set temperature: ${e.toString()}"));
    }
  }

  Future<void> setHVACMode(String entityId, String mode) async {
    try {
      await _service.setHVACMode(entityId, mode);
    } catch (e) {
      emit(HAError("Failed to set HVAC mode: ${e.toString()}"));
    }
  }
  Future<void> setInputNumber(String entityId, double value) async {
    try {
      await _service.setInputNumber(entityId, value);
    } catch (e) {
      debugPrint('setInputNumber error: $e');
    }
  }

  Future<void> setInputSelect(String entityId, String option) async {
    try {
      await _service.setInputSelect(entityId, option);
    } catch (e) {
      debugPrint('setInputSelect error: $e');
    }
  }


  @override
  Future<void> close() {
    _stateChangeSub?.cancel();
    _floorsSub?.cancel();
    _roomsSub?.cancel();
    _entityRegistrySub?.cancel();
    _wsService.disconnect();
    return super.close();
  }
}
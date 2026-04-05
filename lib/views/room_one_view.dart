// room_one_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/ha_cubit/ha_cubit.dart';
import '../cubits/ha_cubit/ha_state.dart';
import '../model/entity_model.dart';

class RoomOneView extends StatelessWidget {
  final String roomId;
  final String roomName;

  const RoomOneView({super.key, required this.roomId, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    roomName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<HACubit, HAState>(
                  builder: (context, state) {
                    if (state is HALoaded) {
                      final devices = state.entities
                          .where((e) => state.entityToRoom[e.entityId] == roomId)
                          .toList();

                      if (devices.isEmpty) {
                        return const Center(
                          child: Text(
                            "No devices in this room",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          return _DeviceTile(device: devices[index]);
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _DeviceTile extends StatefulWidget {
  final EntityModel device;
  const _DeviceTile({required this.device});

  @override
  State<_DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<_DeviceTile> {
  bool _isExpanded = false;

  // ── helpers ──────────────────────────────────────────────────────────────

  /// Returns true for entity types that need an on/off toggle switch
  bool _hasToggle(DeviceType type) {
    return type != DeviceType.inputNumber && type != DeviceType.inputSelect;
  }

  /// Returns true when the tile should show an expand arrow for extra controls
  bool _hasAdvancedControls(DeviceType type) {
    switch (type) {
      case DeviceType.light:
      case DeviceType.fan:
      case DeviceType.cover:
      case DeviceType.climate:
      case DeviceType.mediaPlayer:
      case DeviceType.inputNumber: // always expanded inline
      case DeviceType.inputSelect: // always expanded inline
        return true;
      default:
        return false;
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final deviceType = device.deviceType;
    final bool isOn = device.isOn;

    // input_number & input_select: show controls inline (no expand button)
    final bool alwaysExpanded =
        deviceType == DeviceType.inputNumber ||
            deviceType == DeviceType.inputSelect;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isOn ? Colors.orange.withOpacity(0.2) : Colors.blueGrey[800],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOn ? Colors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                _getIconForDevice(device),
                color: isOn ? Colors.orange : Colors.white,
                size: 30,
              ),
              title: Text(
                device.friendlyName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _getSubtitleText(device),
                style:
                TextStyle(color: isOn ? Colors.orange : Colors.grey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // expand arrow (only for expandable, non-inline types)
                  if (_hasAdvancedControls(deviceType) && !alwaysExpanded)
                    IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                    ),
                  // toggle switch (not for input_number / input_select)
                  if (_hasToggle(deviceType))
                    Switch(
                      value: isOn,
                      onChanged: (_) => context
                          .read<HACubit>()
                          .toggleEntity(device.entityId),
                      activeColor: Colors.orange,
                      activeTrackColor: Colors.orange.withOpacity(0.5),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.blueGrey[900],
                    ),
                ],
              ),
            ),

            // ── advanced / inline controls ──
            if (alwaysExpanded || (_isExpanded && isOn))
              _buildAdvancedControls(context, device, deviceType),
          ],
        ),
      ),
    );
  }

  // ── control panels ────────────────────────────────────────────────────────

  Widget _buildAdvancedControls(
      BuildContext context, EntityModel device, DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return _buildLightControls(context, device);
      case DeviceType.fan:
        return _buildFanControls(context, device);
      case DeviceType.cover:
        return _buildCoverControls(context, device);
      case DeviceType.climate:
        return _buildClimateControls(context, device);
      case DeviceType.mediaPlayer:
        return _buildMediaControls(context, device);
      case DeviceType.inputNumber:
        return _buildInputNumberControls(context, device);
      case DeviceType.inputSelect:
        return _buildInputSelectControls(context, device);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── input_number → slider ─────────────────────────────────────────────────
  Widget _buildInputNumberControls(
      BuildContext context, EntityModel device) {
    final value = device.inputNumberValue;
    final min = device.inputNumberMin;
    final max = device.inputNumberMax;
    final step = device.inputNumberStep;
    final unit = device.inputNumberUnit;

    // Decide how many divisions to use (avoid division by zero)
    final int? divisions =
    step > 0 ? ((max - min) / step).round() : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Icon(_inputNumberIcon(device.entityId),
              color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              activeColor: Colors.orange,
              inactiveColor: Colors.grey,
              onChanged: (v) {
                context
                    .read<HACubit>()
                    .setInputNumber(device.entityId, v);
              },
            ),
          ),
          Text(
            '${value.toStringAsFixed(step < 1 ? 1 : 0)}$unit',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _inputNumberIcon(String entityId) {
    if (entityId.contains('ac') ||
        entityId.contains('temp') ||
        entityId.contains('climate')) return Icons.thermostat;
    if (entityId.contains('bright') ||
        entityId.contains('light') ||
        entityId.contains('spot') ||
        entityId.contains('dim')) return Icons.brightness_6;
    if (entityId.contains('cover') ||
        entityId.contains('blind') ||
        entityId.contains('curtain')) return Icons.curtains;
    return Icons.tune;
  }

  // ── input_select → choice chips ───────────────────────────────────────────
  Widget _buildInputSelectControls(
      BuildContext context, EntityModel device) {
    final options = device.inputSelectOptions;
    final current = device.inputSelectOption;

    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final isSelected = current == opt;
          return ChoiceChip(
            label: Text(opt.toUpperCase()),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                context
                    .read<HACubit>()
                    .setInputSelect(device.entityId, opt);
              }
            },
            selectedColor: Colors.orange,
            backgroundColor: Colors.blueGrey[800],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── light ─────────────────────────────────────────────────────────────────
  Widget _buildLightControls(BuildContext context, EntityModel device) {
    int brightness = device.brightness;
    if (brightness == 0) brightness = 255;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          const Icon(Icons.brightness_6, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: brightness.toDouble(),
              min: 0,
              max: 255,
              activeColor: Colors.orange,
              inactiveColor: Colors.grey,
              onChanged: (value) {
                context
                    .read<HACubit>()
                    .setBrightness(device.entityId, value.toInt());
              },
            ),
          ),
          Text(
            '${(brightness / 255 * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── fan ───────────────────────────────────────────────────────────────────
  Widget _buildFanControls(BuildContext context, EntityModel device) {
    final speeds = ['low', 'medium', 'high'];
    final currentSpeed = device.fanSpeed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Wrap(
        spacing: 12,
        children: speeds.map((speed) {
          final isSelected = currentSpeed == speed;
          return ChoiceChip(
            label: Text(speed.toUpperCase()),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                context
                    .read<HACubit>()
                    .setFanSpeed(device.entityId, speed);
              }
            },
            selectedColor: Colors.orange,
            backgroundColor: Colors.blueGrey[800],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── cover ─────────────────────────────────────────────────────────────────
  Widget _buildCoverControls(BuildContext context, EntityModel device) {
    final position = device.coverPosition;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon:
                const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: () => context
                    .read<HACubit>()
                    .setCoverPosition(device.entityId, 100),
              ),
              Expanded(
                child: Slider(
                  value: position.toDouble(),
                  min: 0,
                  max: 100,
                  activeColor: Colors.orange,
                  inactiveColor: Colors.grey,
                  onChanged: (value) => context
                      .read<HACubit>()
                      .setCoverPosition(device.entityId, value.toInt()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward,
                    color: Colors.white),
                onPressed: () => context
                    .read<HACubit>()
                    .setCoverPosition(device.entityId, 0),
              ),
            ],
          ),
          Text(
            '$position%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── climate ───────────────────────────────────────────────────────────────
  Widget _buildClimateControls(BuildContext context, EntityModel device) {
    final temperature = device.temperature;
    final mode = device.hvacMode;
    final modes = ['cool', 'heat', 'auto', 'off'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: temperature,
                  min: 16,
                  max: 30,
                  divisions: 14,
                  activeColor: Colors.orange,
                  inactiveColor: Colors.grey,
                  onChanged: (value) => context
                      .read<HACubit>()
                      .setTemperature(device.entityId, value),
                ),
              ),
              Text(
                '${temperature.toInt()}°C',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: modes.map((m) {
              final isSelected = mode == m;
              return ChoiceChip(
                label: Text(m.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context
                        .read<HACubit>()
                        .setHVACMode(device.entityId, m);
                  }
                },
                selectedColor: Colors.orange,
                backgroundColor: Colors.blueGrey[800],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── media player ──────────────────────────────────────────────────────────
  Widget _buildMediaControls(BuildContext context, EntityModel device) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
                device.isOn ? Icons.pause : Icons.play_arrow,
                color: Colors.white),
            onPressed: () =>
                context.read<HACubit>().toggleEntity(device.entityId),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          const Icon(Icons.volume_up, color: Colors.white),
          const SizedBox(width: 8),
          const Text('50%', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // ── icon helper ───────────────────────────────────────────────────────────
  IconData _getIconForDevice(EntityModel device) {
    final id = device.entityId;
    final isOn = device.isOn;

    if (id.startsWith('light.') || id.startsWith('input_boolean.')) {
      if (id.contains('light')) {
        return isOn ? Icons.lightbulb : Icons.lightbulb_outline;
      }
      return isOn ? Icons.toggle_on : Icons.toggle_off;
    }
    if (id.startsWith('fan.')) return Icons.air;
    if (id.startsWith('cover.')) return Icons.curtains;
    if (id.startsWith('climate.')) return Icons.ac_unit;
    if (id.startsWith('media_player.')) return Icons.speaker;
    if (id.startsWith('lock.')) {
      return isOn ? Icons.lock_open : Icons.lock;
    }
    if (id.startsWith('vacuum.')) return Icons.cleaning_services;
    if (id.startsWith('switch.')) return Icons.power_settings_new;

    // ── input_number ──
    if (id.startsWith('input_number.')) {
      return _inputNumberIcon(id);
    }

    // ── input_select ──
    if (id.startsWith('input_select.')) {
      if (id.contains('fan')) return Icons.air;
      if (id.contains('mode')) return Icons.settings;
      return Icons.list;
    }

    return Icons.devices;
  }

  // ── subtitle helper ───────────────────────────────────────────────────────
  String _getSubtitleText(EntityModel device) {
    final id = device.entityId;
    final isOn = device.isOn;

    if (id.startsWith('input_number.')) {
      final unit = device.inputNumberUnit;
      final val = device.inputNumberValue;
      return '${val.toStringAsFixed(device.inputNumberStep < 1 ? 1 : 0)}$unit';
    }

    if (id.startsWith('input_select.')) {
      return device.inputSelectOption.toUpperCase();
    }

    if (!isOn) return 'OFF';

    if (id.startsWith('light.')) {
      final brightness = device.brightness;
      final percent = (brightness / 255 * 100).toInt();
      return 'ON • $percent%';
    }
    if (id.startsWith('fan.')) {
      return 'ON • ${device.fanSpeed.toUpperCase()}';
    }
    if (id.startsWith('cover.')) {
      return '${device.coverPosition}%';
    }
    if (id.startsWith('climate.')) {
      final temp = device.temperature.toInt();
      return '${temp}°C • ${device.hvacMode.toUpperCase()}';
    }
    return 'ON';
  }
}
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

class _DeviceTile extends StatelessWidget {
  final EntityModel device;
  const _DeviceTile({required this.device});

  @override
  Widget build(BuildContext context) {
    bool isOn = device.isOn;
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
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(
            isOn ? Icons.lightbulb : Icons.lightbulb_outline,
            color: isOn ? Colors.orange : Colors.white,
            size: 30,
          ),
          title: Text(
            device.friendlyName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isOn ? 'ON' : 'OFF',
            style: TextStyle(color: isOn ? Colors.orange : Colors.grey),
          ),
          trailing: Switch(
            value: isOn,
            onChanged: (_) => context.read<HACubit>().toggleEntity(device.entityId),
            activeColor: Colors.orange,
            activeTrackColor: Colors.orange.withOpacity(0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.blueGrey[900],
          ),
        ),
      ),
    );
  }
}
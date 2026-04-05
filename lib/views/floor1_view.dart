import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:axin/cubits/ha_cubit/ha_cubit.dart';
import 'package:axin/cubits/ha_cubit/ha_state.dart';
import 'package:axin/views/room_one_view.dart';

class FloorOneView extends StatelessWidget {
  final String floorId;
  final String floorName;
  final List<Map<String, dynamic>> rooms;

  const FloorOneView({
    super.key,
    required this.floorId,
    required this.floorName,
    required this.rooms,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff1D243C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          floorName,
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HACubit, HAState>(
        builder: (context, state) {
          if (state is HALoaded) {
            if (rooms.isEmpty) {
              return const Center(
                child: Text("No rooms in this floor", style: TextStyle(color: Colors.white)),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: GridView.builder(
                itemCount: rooms.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth < 600 ? 2 : 3,
                  crossAxisSpacing: screenWidth * 0.03,
                  mainAxisSpacing: screenHeight * 0.02,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final roomId = room['area_id'] as String;
                  final roomName = room['name'] as String;

                  final roomDevices = state.entities
                      .where((e) => state.entityToRoom[e.entityId] == roomId)
                      .toList();
                  final activeCount = roomDevices.where((e) => e.isOn).length;

                  return GestureDetector(
                    onTap: () {
                      final cubit = context.read<HACubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<HACubit>.value(
                            value: cubit,
                            child: RoomOneView(
                              roomId: roomId,
                              roomName: roomName,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF252A3A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: activeCount > 0 ? Colors.orange : Colors.grey.shade700,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.meeting_room,
                            size: screenWidth * 0.1,
                            color: activeCount > 0 ? Colors.orange : Colors.white,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            roomName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (roomDevices.isNotEmpty)
                            Text(
                              '$activeCount/${roomDevices.length} on',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
import 'package:axin/views/hall_one_view.dart';
import 'package:axin/views/hall_two_view.dart';
import 'package:axin/views/roof_view.dart';
import 'package:axin/views/room_one_view.dart';
import 'package:axin/views/room_two_view.dart';
import 'package:flutter/material.dart';

import 'kitchen_view.dart';


class FloorOneView extends StatelessWidget {
  const FloorOneView({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // List of rooms with their corresponding pages
    final List<Map<String, dynamic>> rooms = [
      {"name": "Room 1", "page":  RoomOneView()},
      {"name": "Room 2", "page": const RoomTwoView()},
      {"name": "Kitchen", "page": const KitchenPage()},
      {"name": "Hall 1", "page": const HallOneView()},
      {"name": "Hall 2", "page": const HallTwoView()},
      {"name": "Roof", "page": const RoofView()},
    ];

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
          "Floor One",
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
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
            return GestureDetector(
              onTap: () {
                // Navigate to the respective room page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => rooms[index]["page"]),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF252A3A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange),

                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: screenWidth * 0.1, color: Colors.white),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      rooms[index]["name"],
                      style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

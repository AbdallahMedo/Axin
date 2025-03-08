import 'package:flutter/material.dart';

class AirConditionerView extends StatefulWidget {
  @override
  State<AirConditionerView> createState() => _AirConditionerViewState();
}

class _AirConditionerViewState extends State<AirConditionerView> {
  int counter = 22;

  void increaseTemp() {
    setState(() {
      counter++;
    });
  }

  void decreaseTemp() {
    setState(() {
      counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonSize = screenWidth / 3.5;

    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title:
            Text("Air Conditioner One", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Container(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${counter}",
                      style: TextStyle(
                          fontSize: 100,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("°C",
                          style: TextStyle(fontSize: 28, color: Colors.white)),
                      SizedBox(height: 10),
                      Text("❄ Cooling",
                          style: TextStyle(fontSize: 18, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
        
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     _buildChip("Speed Low"),
            //     Icon(Icons.arrow_right_alt, color: Colors.white),
            //     _buildChip("Direction Up"),
            //     _buildChip("Fixed"),
            //   ],
            // ),
        
            Spacer(),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildControlButton(
                    Icons.power_settings_new,
                    "Power",
                    () {},
                  ),
                  _buildControlButton(
                    Icons.tune,
                    "Mode",
                    () {},
                  ),
                  _buildControlButton(
                    Icons.speed,
                    "Speed",
                    () {},
                  ),
                  _buildControlButton(
                    Icons.minimize_outlined,
                    "Temp",
                    () {
                      decreaseTemp();
                    },
                  ),
                  _buildControlButton(
                    Icons.sync,
                    "Swing",
                    () {},
                  ),
                  _buildControlButton(
                    Icons.add,
                    "Temp",
                    () {
                      increaseTemp();
                    },
                  ),
                  _buildControlButton(
                    Icons.swap_vert,
                    "Direction",
                    () {},
                  ),
                  _buildControlButton(
                    Icons.nightlight_round,
                    "Sleep",
                    () {},
                  ),
                  _buildControlButton(
                    Icons.more_horiz,
                    "More",
                    () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            SizedBox(height: 5),
            Text(label, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

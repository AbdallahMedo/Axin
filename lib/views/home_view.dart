import 'package:axin/model/weather_model.dart';
import 'package:axin/views/drawer.dart';
import 'package:axin/views/floor2_view.dart';
import 'package:axin/views/floor3_view.dart';
import 'package:axin/views/floor4_view.dart';
import 'package:axin/widgets/security_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/get_weather_cubit/get_weather_cubit.dart';
import '../cubits/get_weather_cubit/get_weather_states.dart';
import '../widgets/category_card.dart';
import '../widgets/temp_info.dart';
import 'floor1_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // List of pages corresponding to each category
    final List<Widget> pages = [
      FloorOneView(), // Floor 1
      const FloorTwoView(), // Floor 2 -> Navigates to Security
      const FloorThreeView(), // Floor 3 -> Navigates to Settings
      const FloorFourView(), // Floor 4 -> Navigates to Profile
    ];

    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,color: Colors.white,),
            onPressed: () => Scaffold.of(context).openDrawer(), // Opens Drawer
          ),
        ),
        centerTitle: true,
        title: Text(
          "AXIN",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'BankGothic',
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundImage: const AssetImage("assets/images/person.png"),
            radius: screenWidth * 0.05,
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer:AppDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, Mahmoud 👋',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.07,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              'Welcome to Home,',
              style: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.04,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            BlocBuilder<GetWeatherCubit, WeatherState>(
                builder: (context ,state)

                {
                  if(state is WeatherLoadedState)
                  {
                    return TempInfo(weaher: state.weatherModel);
                  }
                  return const SizedBox();
                }
            ),
            // TempInfo(weaher:weatherModel ,),
            SizedBox(height: screenHeight * 0.03),
            Row(
              children: [
                Text(
                  'Sections',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                SecurityButton(text: "Security"),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: GridView.builder(
                itemCount: pages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth < 600 ? 2 : 3,
                  crossAxisSpacing: screenWidth * 0.02,
                  mainAxisSpacing: screenHeight * 0.02,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return CategoryCard(
                    title: "Floor ${index + 1}",
                    icon: Icons.home,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => pages[index],
                        ),
                      );
                    },
                    isActive: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

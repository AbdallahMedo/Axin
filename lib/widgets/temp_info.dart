import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/get_weather_cubit/get_weather_cubit.dart';
import '../model/weather_model.dart';

class TempInfo extends StatelessWidget {
  const TempInfo({super.key, required this.weaher});
final WeatherModel weaher;
  @override
  Widget build(BuildContext context) {
    WeatherModel weatherModel=BlocProvider.of<GetWeatherCubit>(context).weatherModel!;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xff2C334D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                // Image.asset(
                //   weatherModel.icon,
                //   // 'assets/images/cloudy.png',
                //   height: 50,
                //   width: 50,
                // ),
                Image.network('https:${weatherModel.icon}',height: 50,width: 50,),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                     weatherModel.condition,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                     Text(
                      weatherModel.country,
                      // "Location",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                 Text(
                  "${weatherModel.tempC}°",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "${weatherModel.tempC}°C",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Sensible",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [
                    Text(
                      "${weatherModel.humidity}%",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Humidity",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "${weatherModel.windKph} Km//h",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Wind",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

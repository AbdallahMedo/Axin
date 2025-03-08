import 'package:axin/theme/theme_provider.dart';
import 'package:axin/views/home_view.dart';
import 'package:axin/views/spalsh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'cubits/get_weather_cubit/get_weather_cubit.dart';
import 'cubits/get_weather_cubit/get_weather_states.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetWeatherCubit(),
      child: Builder(
        builder:(context)=> BlocBuilder<GetWeatherCubit ,WeatherState>(
          builder: (context,state)
          {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
            );

          },

        ),
      ),
    );
  }
}


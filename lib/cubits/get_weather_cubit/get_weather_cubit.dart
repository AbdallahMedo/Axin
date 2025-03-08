import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../model/weather_model.dart';
import '../../services/weather_service.dart';
import 'get_weather_states.dart';

class GetWeatherCubit extends Cubit<WeatherState>{
  GetWeatherCubit(): super(WeatherInitialState());
   WeatherModel? weatherModel;



  getWeather()async
  {
    try {
      weatherModel = await WeatherService(Dio()).getCurrentWeather();
      emit(WeatherLoadedState(weatherModel!));
    }catch(e)
    {
      emit(WeatherFailureState());
    }

    }
  }

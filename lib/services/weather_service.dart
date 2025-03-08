import 'package:dio/dio.dart';

import '../model/weather_model.dart';

class WeatherService {
  final Dio dio;
  final String baseUrl = 'http://api.weatherapi.com/v1';
  final String weatherApiKey = '0f748d54803e40a7820134635240112';

  WeatherService(this.dio);

  Future<WeatherModel> getCurrentWeather() async {
    try {
      Response response = await dio
          .get('$baseUrl/forecast.json?key=$weatherApiKey&q=Cairo&days=1');
      WeatherModel weatherModel = WeatherModel.fromJson(response.data);

      return weatherModel;
    } on DioException catch (e) {
      final String errorMessage = e.response?.data['error']['message'] ??
          'Oops there was an error, try later';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Oops there was an error, try later');
    }
  }
}

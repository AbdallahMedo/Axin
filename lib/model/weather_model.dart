import 'dart:convert';

class WeatherModel {
  final String country;
  final double tempC;
  final String condition;
  final String icon;
  final double windKph;
  final int humidity;

  WeatherModel({
    required this.country,
    required this.tempC,
    required this.condition,
    required this.icon,
    required this.windKph,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      country: json['location']['country'],
      tempC: json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      icon: json['current']['condition']['icon'],
      windKph: json['current']['wind_kph'].toDouble(),
      humidity: json['current']['humidity'].toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'tempC': tempC,
      'condition': condition,
      'icon': icon,
      'windKph': windKph,
      'humidity': humidity,
    };
  }
}

// Function to parse JSON
WeatherModel parseWeather(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return WeatherModel.fromJson(parsed);
}

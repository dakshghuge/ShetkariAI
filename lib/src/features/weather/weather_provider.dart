import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

class WeatherData {
  final String city;
  final double temp;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;
  final List<String> alerts;

  WeatherData({
    required this.city,
    required this.temp,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    this.alerts = const [],
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    List<String> alerts = [];
    if (json.containsKey('alerts')) {
      for (var alert in json['alerts']) {
        alerts.add(alert['event'] ?? '');
      }
    }
    
    // Custom smart logic for agri-alerts if API doesn't provide them
    double wind = (json['wind']['speed'] as num).toDouble();
    double temp = (json['main']['temp'] as num).toDouble();
    if (wind > 15) alerts.add('वेगवान वारा: फवारणी टाळा (High Wind)');
    if (temp > 35) alerts.add('अति उष्णता: सिंचन वाढवा (High Heat)');
    
    return WeatherData(
      city: json['name'] ?? 'Unknown',
      temp: temp,
      description: json['weather'][0]['description'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: wind,
      icon: json['weather'][0]['icon'] ?? '01d',
      alerts: alerts,
    );
  }
}

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherData>> {
  WeatherNotifier() : super(const AsyncValue.loading()) {
    getWeather();
  }

  Future<void> getWeather() async {
    state = const AsyncValue.loading();
    try {
      if (AppConfig.openWeatherApiKey == 'YOUR_OPENWEATHER_API_KEY' || AppConfig.openWeatherApiKey.isEmpty) {
        state = AsyncValue.data(WeatherData(
          city: 'पुणे (Demo)',
          temp: 28.5,
          description: 'अंशतः ढगाळ',
          humidity: 75,
          windSpeed: 12.0,
          icon: '03d',
          alerts: ['पाऊस येण्याची शक्यता आहे (Rain Alert)'],
        ));
        return;
      }

      Position? position = await _determinePosition();
      
      String url;
      if (position != null) {
        url = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${AppConfig.openWeatherApiKey}&units=metric&lang=mr';
      } else {
        url = 'https://api.openweathermap.org/data/2.5/weather?q=Pune&appid=${AppConfig.openWeatherApiKey}&units=metric&lang=mr';
      }
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = AsyncValue.data(WeatherData.fromJson(data));
      } else {
        state = AsyncValue.error('API Error: ${response.statusCode}', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error('Error: $e', StackTrace.current);
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (_) {
      return await Geolocator.getLastKnownPosition();
    }
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherData>>((ref) {
  return WeatherNotifier();
});

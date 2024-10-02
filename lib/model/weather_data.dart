
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;
import 'package:weather_app/model/weather_model.dart';


class WeatherData {
  final String apiKey = "your apikey";

  Future<WeatherModel> getWeatherData(String cityName) async {
    print("City Name: $cityName");
    var response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric"));
    var data = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(data);
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  Future<String?> getUserLocationPermission(BuildContext context) async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      // Show dialog if permission is permanently denied
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Location Permission Disabled"),
          content: const Text(
            "Location permission is permanently denied. Please enable it from the device settings to fetch weather data.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return null;
    } else if (permission == LocationPermission.denied) {
     
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Location Permission Denied"),
          content: const Text(
            "You have denied location access. Please allow location permission to fetch the weather.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return null;
    }
  }

 
  if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(accuracy: LocationAccuracy.low));
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String? cityName = placemarks[0].locality;
      return cityName ?? "";
    } catch (e) {
      
      print("Error getting location: $e");
      return null;
    }
  }

  return null;
}
}

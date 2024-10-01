import 'package:flutter/material.dart';

import 'package:weather_app/model/weather_data.dart';
import 'package:weather_app/model/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData weatherData = WeatherData();
  WeatherModel? weather;
  TextEditingController cityNameController = TextEditingController();

  String? searchCity;
  searchWeather() async {
    showDialog(context: context, builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),);
    try {
      final data = await weatherData.getWeatherData(searchCity!);
      setState(() {
        weather = data;
      });
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      showDialog(context: context, builder: (context) => const AlertDialog(
        title: Center(child: Text("Error")),
        content: Text("City not Found try something else"),
      ),);
    }
  }

  fetchweatherData() async {
  try {
    String? cityName = await weatherData.getUserLocationPermission(context);

    if (cityName == null || cityName.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Denied"),
          content: const Text("Please enable location permissions to fetch weather data and then press on Current location button."),
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
      return; 
    }

    final data = await weatherData.getWeatherData(cityName);
    setState(() {
      weather = data;
    });
  } catch (e) {
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Error")),
        content: const Text("Failed to fetch weather data. Please try again."),
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
    print("Error fetching weather data: ${e.toString()}");
  }
}

  @override
  void initState() {
    fetchweatherData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellowAccent.shade100,
        onPressed: () {
          fetchweatherData();
        },
        child: const Icon(Icons.location_searching_sharp),
      ),
      body: Stack(
        children: [
          Image.asset(
            "assets/background.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          weather != null?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: ListTile(
                  title: TextField(
                    controller: cityNameController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search City Weather",
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  trailing: IconButton(
                      style: ButtonStyle(
                          iconSize: const WidgetStatePropertyAll(35),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          backgroundColor: const WidgetStatePropertyAll(Colors.grey)),
                      onPressed: () {
                        searchCity = cityNameController.text;
                        searchWeather();
                        cityNameController.clear();
                      },
                      icon: const Icon(
                        Icons.done,
                      )),
                ),
              ),
              const SizedBox(height: 80,),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    weather!.name.toString() ,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.amber),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 105),
                child: Text(
                  "${weather!.main!.temp!.toDouble().toStringAsFixed(1)}°C",
                  style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 45),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 200),
                child: Text(weather!.weather![0].description!.toUpperCase(),style: TextStyle(
                        color: Colors.amberAccent.shade100,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),),
              ),
             
             
            ],
          ): const Center(
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }
}

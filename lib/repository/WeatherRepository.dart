import 'dart:collection';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:weather_app/model/Forecast.dart';
import 'package:weather_app/model/WeatherModel.dart';

import '../model/WeatherResponse.dart';

class WeatherRepository {
  Future<List<Forecast>> getForecast(String city) async {
    // final result = await http.Client().get("https://api.openweathermap.org/data/2.5/weather?q=$city&APPID=43ea6baaad7663dc17637e22ee6f78f2");
    final result = await http.Client().get(
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=43ea6baaad7663dc17637e22ee6f78f2");

    if (result.statusCode != 200) throw Exception();

    final weatherResponses = parsedJson(result.body);

    return generateForecast(weatherResponses);
  }

  List<WeatherResponse> parsedJson(final response) {
    final jsonDecoded = json.decode(response);

    final jsonWeather = jsonDecoded["list"] as List;

    List<WeatherResponse> weatherResponse = jsonWeather
        .map((tagJson) => WeatherResponse.fromJson(tagJson))
        .toList();

    return weatherResponse;
  }

  List<Forecast> generateForecast(
      List<WeatherResponse> weatherResponse) {
    DateTime day = convertDateFromString(weatherResponse[0].dt_txt);
    List<Forecast> forecast = [];

    for (var weather in weatherResponse) {
      DateTime date = convertDateFromString(weather.dt_txt);

      if (date.day.toString() != day.day.toString()) {
        final weatherModel = createWeatherModelList(date, weatherResponse);
        forecast.add(new Forecast(date.month, date.day, weatherModel));
        day = date;
      }

      if (forecast.length == 3) {
        break;
      }
    }
    return forecast;
  }

  List<WeatherModel> createWeatherModelList(DateTime dateTime, List<WeatherResponse> weatherResponse) {

    List<WeatherModel> weatherModel = [];
    var isSaved = true;

    for (var weather in weatherResponse) {

      DateTime date = convertDateFromString(weather.dt_txt);
      if (date.day == dateTime.day) {
        if (isSaved) {
          weatherModel.add(new WeatherModel(date.hour, weather.main['temp']));
          isSaved = false;
        } else {
          isSaved = true;
        }
      }
    }

    return weatherModel;
  }

  DateTime convertDateFromString(String strDate) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return dateFormat.parse(strDate);
  }

}

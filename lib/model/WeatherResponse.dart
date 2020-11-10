import 'dart:convert';

class WeatherResponse {

  final main;
  final dt_txt;

  WeatherResponse(this.main, this.dt_txt);

  factory WeatherResponse.fromJson(Map<String, dynamic> json){
    return WeatherResponse(
      json["main"],
      json["dt_txt"],
    );
  }

}
class WeatherModel {
  final hour;
  final temp;

  double get getTemp => temp - 272.5;

  WeatherModel(this.hour, this.temp);

}

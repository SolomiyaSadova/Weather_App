import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/model/Forecast.dart';
import 'package:weather_app/model/WeatherModel.dart';
import 'package:weather_app/ui/widget/ForecastWidget.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../WeatherBloc.dart';

class ShowForecast extends StatelessWidget {
  List<Forecast> forecast;
  final city;

  ShowForecast(this.forecast, this.city);

  Widget generateForecast(BuildContext context, Forecast item) {
    List<Widget> list = new List<Widget>();
    list.add(new Column(
      children: [
        new SizedBox(
          width: 80,
        ),
        new Text(
          item.day.toString() + "/" + item.month.toString() + ": ",
          style: TextStyle(
              color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        new SizedBox(
          height: 20,
        ),
        new Column(children: <Widget>[
          generateDailyForecast(context, item.weatherModel)
        ]),
        new SizedBox(
          height: 25,
        ),
      ],
    ));

    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: list);
  }

  Widget generateDailyForecast(
      BuildContext context, List<WeatherModel> weatherModels) {
    List<Widget> list = new List<Widget>();
    for (var weatherModel in weatherModels) {
      double temperature = weatherModel.getTemp;
      list.add(
        new Column(
          children: <Widget>[
            Text(
              weatherModel.hour.toString() + ":00",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            Text(
              temperature.round().toString() + "C  ",
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            getWeatherType(temperature),
            SizedBox(
              width: 50,
            )
          ],
        ),
      );
    }
    return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 32, left: 32, top: 10),
        child: Column(
          children: <Widget>[
            Text(
              city,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      getForecastForCurrentHour(forecast[0]).toString(),
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    getDailyWeatherType(getForecastForCurrentHour(forecast[0])),
                  ]),
            ]),

            SizedBox(
              height: 50,
            ),

            // Text(weather.hour,style: TextStyle(color: Colors.white70, fontSize: 14),),
            // Text(weather.getTemp.round().toString()+"C",style: TextStyle(color: Colors.white70, fontSize: 20),),

            Column(children: <Widget>[
              for (var item in forecast) generateForecast(context, item),
            ]),
          //  BackButtonIcon()
          ],
        ));
  }

  getWeatherType(double temp) {
    if (temp < 10 && temp > 5) {
      return Wind();
    } else if (temp > 10) {
      return Sun();
    } else {
      return Snow();
    }
  }

  getForecastForCurrentHour(Forecast forecast) {
    return forecast.weatherModel[2].getTemp.round();
  }

  getDailyWeatherType(int temp) {
    if (temp > 15) {
      return Icon(
        WeatherIcons.day_sunny,
        size: 50,
        color: Colors.white70,
      );
    } else if (temp < 15 && temp > 5) {
      return Icon(
        WeatherIcons.day_windy,
        size: 50,
        color: Colors.white70,
      );
    } else if (temp < 5 && temp > -5) {
      return Icon(
        WeatherIcons.day_snow,
        size: 50,
        color: Colors.white70,
      );
    } else {
      return Icon(
        WeatherIcons.snow_wind,
        size: 50,
        color: Colors.white70,
      );
    }
  }
}

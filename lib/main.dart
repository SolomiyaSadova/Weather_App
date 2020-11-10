import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/repository/WeatherRepository.dart';
import 'WeatherBloc.dart';
import 'model/Forecast.dart';
import 'model/WeatherModel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.grey[900],
          body: BlocProvider(
            builder: (context) => WeatherBloc(WeatherRepository()),
            child: SearchPage(),
          ),
        ));
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);
    var cityController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //
        // Center(
        //     child: Container(
        //       child: FlareActor("assets/WorldSpin.flr", fit: BoxFit.contain, animation: "roll",),
        //       height: 300,
        //       width: 300,
        //     )
        // ),

        BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state is WeatherIsNotSearched)
              return Container(
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Search Weather",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Colors.white70,
                                style: BorderStyle.solid)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Colors.blue, style: BorderStyle.solid)),
                        hintText: "City Name",
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: FlatButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        onPressed: () {
                          weatherBloc.add(FetchWeather(cityController.text));
                        },
                        color: Colors.lightBlue,
                        child: Text(
                          "Search",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              );
            else if (state is WeatherIsLoading)
              return Center(child: CircularProgressIndicator());
            else if (state is WeatherIsLoaded)
              return ShowForecast(state.getForecast, cityController.text);
            else
              return Text(
                "Error",
                style: TextStyle(color: Colors.white),
              );
          },
        )
      ],
    );
  }
}

class ShowForecast extends StatelessWidget {
  List<Forecast> forecast;
  final city;

  ShowForecast(this.forecast, this.city);

  Widget getTextWidgets(Forecast item) {
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
        new Row(children: <Widget>[generateColumns(item.weatherModel)]),
        new SizedBox(
          height: 30,
        ),

      ],
    ));

    return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: list);
  }

  Widget generateColumns(List<WeatherModel> weatherModels) {
    List<Widget> list = new List<Widget>();
    for (var weatherModel in weatherModels) {
      list.add(
        new Column(
          children: <Widget>[
            Text(
              weatherModel.hour.toString() + ":00",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            Text(
              weatherModel.getTemp.round().toString() + "C  ",
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      );
    }
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 32, left: 32, top: 1),
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

            // Text(weather.hour,style: TextStyle(color: Colors.white70, fontSize: 14),),
            // Text(weather.getTemp.round().toString()+"C",style: TextStyle(color: Colors.white70, fontSize: 20),),

            Row(
                children: <Widget>[
                  for (var item in forecast) getTextWidgets(item),

                ]
              //  getTextWidgets(),
            ),

            SizedBox(
              height: 20,
            ),

            Container(
              width: double.infinity,
              height: 50,
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                onPressed: () {
                  BlocProvider.of<WeatherBloc>(context).add(ResetWeather());
                },
                color: Colors.lightBlue,
                child: Text(
                  "Search",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            )
          ],
        ));
  }
}

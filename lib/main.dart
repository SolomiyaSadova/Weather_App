import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/repository/WeatherRepository.dart';
import 'package:weather_app/service/address_search_service.dart';
import 'package:weather_app/service/place_service.dart';
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
            child: SearchPage(title: 'Places Autocomplete Demo'),
          ),
        ));
  }
}

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SearchPage createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  var cityController = TextEditingController();

  final _controller = TextEditingController();

  String _city = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);

    return
      DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/fon.jpg"), fit: BoxFit.cover),
        ),
      child:
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherIsNotSearched)
                return Container(
                  padding: EdgeInsets.fromLTRB(10, 22, 10, 2),
                  child: TextField(
                    controller: _controller,
                    readOnly: true,
                    onTap: () async {
                      // generate a new token here
                      final sessionToken = Uuid().v4();
                      final Suggestion result = await showSearch(
                        context: context,
                        delegate: AddressSearch(sessionToken),
                      );
                      // This will change the text displayed in the TextField
                      if (result != null) {
                        final placeDetails =
                        await PlaceApiProvider(sessionToken)
                            .getPlaceDetailFromId(result.placeId);
                        setState(() {
                          _controller.text = result.description;
                          _city = placeDetails.city;
                          weatherBloc.add(FetchWeather(_city));
                        });
                      }
                    },
                    style: TextStyle(fontSize: 22.0, color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Enter your address",
                      hintStyle: TextStyle(
                          color: Colors.black, fontStyle: FontStyle.italic),
                      // contentPadding: EdgeInsets.only(left: 0.0, top: 0.0),
                    ),
                  ),
                );
              else if (state is WeatherIsLoading)
                return Center(child: CircularProgressIndicator());
              else if (state is WeatherIsLoaded)
                return ShowForecast(state.getForecast, _city);
              else
                return Text(
                  "Error",
                  style: TextStyle(color: Colors.white),
                );
            },
          )
        ],
      )
    )
        ;
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

            Row(children: <Widget>[
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

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:weather_app/service/address_search_service.dart';
import 'package:weather_app/service/place_service.dart';
import 'package:weather_app/ui/screen/ForecatScreen.dart';

import '../../WeatherBloc.dart';

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

    return DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/wallpaper.jpeg"), fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) {
                if (state is WeatherIsNotSearched)
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TextField(
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
                                color: Colors.black,
                                fontStyle: FontStyle.italic),
                            // contentPadding: EdgeInsets.only(left: 0.0, top: 0.0),
                          ),
                        ),
                        SizedBox(
                          height: 120,
                        ),
                        Center(
                            child: Container(
                          child: FlareActor(
                            "assets/WorldSpin.flr",
                            fit: BoxFit.contain,
                            animation: "roll",
                          ),
                          height: 300,
                          width: 300,
                        )),
                      ]);
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
            ),
          ],
        ));
  }
}

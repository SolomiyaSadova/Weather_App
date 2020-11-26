import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class Snow extends StatefulWidget {
  Snow({Key key}) : super(key: key);

  @override
  _SnowWidget createState() => _SnowWidget();
}

class Sun extends StatefulWidget {
  Sun({Key key}) : super(key: key);

  @override
  _SunWidget createState() => _SunWidget();
}

class Wind extends StatefulWidget {
  Wind({Key key}) : super(key: key);

  @override
  _WindWidget createState() => _WindWidget();
}

class _SunWidget extends State<Sun> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RotationTransition(
        turns: _animation,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.wb_sunny, size: 30.0, color: Colors.amber),
        ),
      ),
    );
  }
}

class _WindWidget extends State<Wind> with TickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  Color color;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 15),
      reverseDuration: Duration(seconds: 15),
    )..repeat(reverse: true);
    animation = ColorTween(begin: Colors.black12, end: Colors.white)
        .animate(controller);

    animation.addListener(() {
      setState(() {
        color = animation.value;
      });
    });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Icon(
      Icons.cloud,
      size: 30.0,
      color: color,
    )
    ;
  }
}

class _SnowWidget extends State<Snow> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this, value: 0.1)
      ..repeat(reverse: true);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);

    _controller.forward();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: Alignment.center,
      child: Icon(WeatherIcons.day_snow, size: 30.0, color: Colors.white),
    );
  }
}

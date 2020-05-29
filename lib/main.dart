import 'package:flutter/material.dart';
import 'package:maps/utils/geolocationBloc.dart';
import './pages/home.dart';
import './pages/location_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './utils/geolocationBloc.dart';
import './pages/review_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GeolocationBloc(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Maps Avancado',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: LocationPage(),//SplashPage(Permission.locationWhenInUse),
            routes: {
              'home': (_) => HomePage(),
              'location': (_) => LocationPage(),
              'review': (_) => ReviewPage(),
            },
      ),
    );
  }
}


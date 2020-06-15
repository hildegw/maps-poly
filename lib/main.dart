import 'package:flutter/material.dart';
import 'package:maps/utils/geolocationBloc.dart';
import './pages/home.dart';
import './pages/location_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './utils/geolocationBloc.dart';

// ~/Android/Sdk/emulator/emulator -avd Pixel_XL_API_29

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
              primarySwatch: Colors.deepPurple,
              buttonColor: Color(0xccede7f6), //green button              
              textTheme: TextTheme(
                headline1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
                headline2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                subtitle1: TextStyle(fontSize: 14.0, color: Colors.deepPurple),
                subtitle2: TextStyle(fontSize: 14.0, color: Colors.grey[800]),
              ),
            ),
            home: LocationPage(),//SplashPage(Permission.locationWhenInUse),
            routes: {
              'home': (_) => HomePage(),
              'location': (_) => LocationPage(),
            },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/pages/review_page.dart';
import '../utils/geolocationBloc.dart';
import './track_page.dart';
import 'dart:math' as math;
import 'package:convex_bottom_bar/convex_bottom_bar.dart';


class LocationPage extends StatefulWidget {
  
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> with SingleTickerProviderStateMixin {

  List<Widget> listScreens;
  int tabIndex = 0;



  @override
  void initState() {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    geolocationBloc.add(GeoEvent.start);
    listScreens = [
      TrackPage(),
      ReviewPage(),
      TrackPage(),
    ];    
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    final iconColor = Theme.of(context).bottomAppBarColor;


    return SafeArea(
        child: Scaffold(
          body: listScreens[tabIndex],
          bottomNavigationBar: ConvexAppBar(
            items: [
              TabItem(
                title: 'Track',
                icon: Icons.track_changes, 
              ),
              TabItem(
                icon: Icons.grid_on, 
                title: 'Review'
              ),
              TabItem(
                icon: Icons.settings, 
                title: 'Settings'
              ),
            ],

            height: 50.0,
            top: -10.0,
            activeColor: Theme.of(context).bottomAppBarColor,
            color: Theme.of(context).buttonColor,
            backgroundColor: Theme.of(context).primaryColor,
            //currentIndex: tabIndex,
            onTap: (int index) {
              setState(() {
                tabIndex = index;
              });
            },
          )
        )
      );
  }
}
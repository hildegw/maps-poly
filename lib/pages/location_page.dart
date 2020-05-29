import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/pages/review_page.dart';
import '../utils/geolocationBloc.dart';
import './track_page.dart';

class LocationPage extends StatefulWidget {
  
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> with SingleTickerProviderStateMixin {

  List<Widget> listScreens;
  int tabIndex = 0;

  List<BottomNavigationBarItem> _tabsMenu =  [
    BottomNavigationBarItem(icon: Icon(Icons.directions_car), title: Text('Track')),
    BottomNavigationBarItem(icon: Icon(Icons.directions_transit), title: Text('Review')),
    BottomNavigationBarItem(icon: Icon(Icons.directions_bike), title: Text('Track')),
  ];


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

    return SafeArea(
        child: Scaffold(
          body: listScreens[tabIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: _tabsMenu,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Theme.of(context).primaryColor,
            currentIndex: tabIndex,
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
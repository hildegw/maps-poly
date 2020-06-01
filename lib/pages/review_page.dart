import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/map_review.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;


extension Precision on double {
    double toPrecision(int fractionDigits) {
        double mod = math.pow(10.0, fractionDigits.toDouble());
        return ((this * mod).round().toDouble() / mod);
    }
}


class ReviewPage extends StatefulWidget {
  
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {

  List<LatLng> _oldRoute = List();
  String _selectedRouteName;

  @override
  void initState() {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    //geolocationBloc.setSelectedRouteName('TODO');
    geolocationBloc.add(GeoEvent.showSaved);
    getGeoBlockData(geolocationBloc);
    super.initState();
  }

  getGeoBlockData(GeolocationBloc geolocationBloc) async {
    _oldRoute = await geolocationBloc.state.oldRoute;
    List<String> allSavedPaths = await geolocationBloc.state.savedPaths;
    _selectedRouteName = allSavedPaths != null && allSavedPaths.length > 0
      ? allSavedPaths[0] : null;
    print(geolocationBloc.state.oldRoute );
    print(geolocationBloc.state.savedPaths.toString());
  }

  String posString() {
    return _oldRoute != null && _oldRoute.length > 0
      ? Position(
        latitude: _oldRoute[_oldRoute.length-1].latitude.toPrecision(6), 
        longitude: _oldRoute[_oldRoute.length-1].longitude.toPrecision(6)
      ).toString() : '';
  }

//TODO fetch route data with selected route name
//call showSavedRoute with name



  Widget FilesDropDown(context, state, geolocationBloc) {
    print('dropdown value in review page $_selectedRouteName ');
    return Container(
        height: 40,
        width: 300,
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Theme.of(context).buttonColor,
        ),   
      child: DropdownButton<String>(
        value: _selectedRouteName,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: Theme.of(context).textTheme.headline2,
        onChanged: (String newValue) { 
          geolocationBloc.setSelectedRouteName(newValue);
          geolocationBloc.add(GeoEvent.showSaved);
          setState(() { _selectedRouteName = newValue;}); 
        },
        items: state.savedPaths.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList()
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);

    return BlocBuilder<GeolocationBloc, GeoState> (
        builder: (context, state) {
        return Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: <Widget>[
              
              MapReview(), // map or spinner
              
              Positioned( //Lat Lon info top 
                left: 10,
                top:  10,
                child: Container(
                  width: 270,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).buttonColor,
                  ),
                  child: Text(
                    posString(),
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Positioned(  //drop down for files
                left: 30,
                bottom: 30,                  
                child: FilesDropDown(context, state, geolocationBloc),
              ),

              Positioned(  //edit button
                left: 90,
                bottom: 30,              
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).buttonColor,
                  ),                
                  child: IconButton(
                        onPressed: () => geolocationBloc.add(GeoEvent.deleteRoute), 
                        icon:Icon(Icons.edit, size: 40.0),
                        color: Theme.of(context).accentColor,
                        padding: EdgeInsets.only(bottom: 0),
                      ),
                )
              ),


          
          ],
        ),
      );
    });
  }
}
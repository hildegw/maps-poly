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


  @override
  void initState() {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    //geolocationBloc.setSelectedRouteName('TODO');
    geolocationBloc.add(GeoEvent.showSaved);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    _oldRoute = geolocationBloc.state.oldRoute;

    String posString = _oldRoute != null && _oldRoute.length > 0
      ? Position(
        latitude: _oldRoute[0].latitude.toPrecision(6), 
        longitude: _oldRoute[0].longitude.toPrecision(6)
      ).toString() : '';

    print(posString);

    return BlocBuilder<GeolocationBloc, GeoState> (
        builder: (context, state) {
        return Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: <Widget>[
              MapReview(),
              
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
                    posString,
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),


              Center(child: Text(state.position.toString()),),

              Positioned(  //start stop button
                left: 30,
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

              Center(child: Text(state.savedPaths.toString()),),

          
          ],
        ),
      );
    });
  }
}
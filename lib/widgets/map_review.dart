import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/geolocationBloc.dart';



class MapReview extends StatelessWidget {

  final Completer<GoogleMapController> _controller = Completer();
  Map<PolylineId, Polyline> _polylines = Map();
  List<LatLng> _oldRoute = List();


  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);

    final _oldRoute = geolocationBloc.state.oldRoute;
   //print('route ${_oldRoute[0].toString()} ');

    final myPolyline = Polyline(
        polylineId: PolylineId("me"),
        points: _oldRoute,
        color: Colors.cyanAccent,
        width: 8
      );
    _polylines[myPolyline.polylineId] = myPolyline;


    return BlocBuilder<GeolocationBloc, GeoState> (
        builder: (context, state) {
        return geolocationBloc.state.status == Status.showSaved
          ? GoogleMap(
            mapType: MapType.hybrid,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(target: _oldRoute[0], zoom: 14),
            polylines: Set.of(_polylines.values),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            //onTap: (pos) => print(pos.toString()),
          ) : CircularProgressIndicator();
      });
  }

}
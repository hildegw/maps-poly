import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/geolocationBloc.dart';



class MapReview extends StatelessWidget {

  final Completer<GoogleMapController> _controller = Completer();
  Map<PolylineId, Polyline> _polylines = Map();
  List<LatLng> _oldRoute = List();


  // _move(Position position) async {
  //   final cameraUpdate = CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude));
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(cameraUpdate);
  // }
 

  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);

      _oldRoute = geolocationBloc.state.oldRoute;

      final myPolyline = Polyline(
          polylineId: PolylineId("me"),
          points: _oldRoute,
          color: Colors.deepPurpleAccent[100],
          width: 6
        );
      _polylines[myPolyline.polylineId] = myPolyline;

      return BlocBuilder<GeolocationBloc, GeoState> (
          builder: (context, state) {
          return geolocationBloc.state.status != Status.showSaved
            ? Center(child: CircularProgressIndicator())  
            : GoogleMap(
                mapType: MapType.hybrid,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition: _oldRoute != null && _oldRoute.length > 0
                  ? CameraPosition(target: _oldRoute[_oldRoute.length-1], zoom: 14)
                  : CameraPosition(target: LatLng(state.position.latitude, state.position.longitude), zoom: 14),
                polylines: Set.of(_polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              );
          });
        
  }

}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/geolocationBloc.dart';



class MapSample extends StatelessWidget {

  final Completer<GoogleMapController> _controller = Completer();


  _move(Position position) async {
    final cameraUpdate = CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude));
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(cameraUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);

      if (geolocationBloc.state.status == Status.moving) {
        _move(geolocationBloc.state.position);
        print('moving? ${geolocationBloc.state.position} ');
      }

    return BlocBuilder<GeolocationBloc, GeoState> (
        builder: (context, state) {
        return geolocationBloc.state.status == Status.loading
          ? CircularProgressIndicator()        
          : GoogleMap(
            mapType: MapType.hybrid,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(target: LatLng(state.position.latitude, state.position.longitude), zoom: 14),
            polylines: Set.of(state.polylines.values),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            //onTap: (pos) => print(pos.toString()),
          );
      });
  }

}
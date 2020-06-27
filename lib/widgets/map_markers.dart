import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/geolocationBloc.dart';


class MapMarkers extends StatefulWidget {
  @override
  _MapMarkersState createState() => _MapMarkersState();
}

class _MapMarkersState extends State<MapMarkers> {

  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set();
  int _counter = 0;
  //TODO handover to bloc and parent:_selectedLatLng;

  _addMarker(LatLng latlng) {
    print('add marker $latlng');
    Marker marker = Marker(
      markerId: MarkerId(_counter.toString()),
      infoWindow: InfoWindow(
          title: _counter.toString(),
          snippet: "snippetInfoWin"),
      position: latlng,
    );
    setState(() =>_markers.add(marker));
    _counter++;
  }


  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);

  print('markers ${_markers.toString()} ');

    return BlocBuilder<GeolocationBloc, GeoState> (
        builder: (context, state) {
        return geolocationBloc.state.status == Status.loading
          ? Center(child: CircularProgressIndicator())        
          : GoogleMap(
              mapType: MapType.hybrid,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(target: LatLng(state.position.latitude, state.position.longitude), zoom: 14),
              polylines: Set.of(state.polylines.values),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
              onTap: (latlng) => _addMarker(latlng),
          );
      });
  }

}
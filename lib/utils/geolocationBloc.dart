import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:maps/utils/file_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import './geolocationApi.dart';


enum GeoEvent { start, move, nextMove, stop, reset, error, saveRoute, showSaved }
enum Status { loading, showing, moving, reset, error }


class GeoState {
  final Status status;
  final Position position;
  final Map<PolylineId, Polyline>  polylines;
  final List<LatLng> route;
  final String error;
  GeoState({ this.status = Status.loading, this.position, this.polylines, this.route, this.error });

  GeoState copyWith({
    Status status,
    Position position,
    Map<PolylineId, Polyline> polylines,
    List<LatLng> route,
    String error,
  }) {
    return GeoState(
      status: status ?? this.status,
      position: position ?? this.position,
      polylines: polylines ?? this.polylines,
      route: route ?? this.route,
      error: error ?? this.error,
    );
  }
}


class GeolocationBloc extends Bloc<GeoEvent, GeoState> {

 String _errorText = '';
  Position _position;

  StreamSubscription<Position> _positionStream;
  Map<PolylineId, Polyline> _polylines = Map();
  List<LatLng> _myRoute = List();
  FileIo _fileIo = FileIo();


  _getPosition() async { //get initial location
    try {
      _position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);      
      if (_position != null) {
        print(_position);  
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('currentLat', _position.latitude);
        await prefs.setDouble('currentLon', _position.longitude);
      } else throw('no position available');
    } catch(err) { 
        print('catching error in getPosition $err'); 
        _errorText = err.toString();
        this.add(GeoEvent.error);
      }
  }

  _startTracking() {
    final geolocator = Geolocator();
    final locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 5);
    _positionStream = geolocator.getPositionStream(locationOptions).listen(_onLocationUpdate);
  }

  _stopTracking() {
    if (_positionStream != null) {
      _positionStream.cancel();
      _positionStream = null;
    }
  }

  _onLocationUpdate(Position position) {
      if (position != null) {
        _position = position;
        final latLng = LatLng(position.latitude, position.longitude);
        _myRoute.add(latLng);
        final myPolyline = Polyline(
            polylineId: PolylineId("me"),
            points: _myRoute,
            color: Colors.cyanAccent,
            width: 8
          );
        _polylines[myPolyline.polylineId] = myPolyline;
        this.add(GeoEvent.nextMove); //keep moving
      } else {
         print('error getting updated position from stream'); 
        _errorText = 'no position available';
        this.add(GeoEvent.error);
      }
    }

  _saveRoute() async { //save to app file storage
    try {
      await _fileIo.writeRoute(_myRoute);
    } catch(err) {  print('catching error saving route $err');  }
  }

  _showSavedRoute() async {
    try {
      List<LatLng> oldRoute =  await _fileIo.readRoute();
      oldRoute != null ?  print('old route ${oldRoute.toString()} ') : print('no route data');
    } catch(err) {  print('catching error showing saved route $err');  }
  }


  @override
  GeoState get initialState => GeoState(status: Status.loading, polylines: _polylines);

  @override 
  Stream<GeoState> mapEventToState(GeoEvent event) async* {
    switch (event) {
      case GeoEvent.start:
        await _getPosition();
        yield GeoState(status: Status.showing, position: _position, polylines: _polylines);
        if (_position != null) print('done state ${state.position} ');
        else print('error state ${state.error} ');
        break;

      case GeoEvent.move:
        await _startTracking();
        yield state.copyWith(
          status: Status.moving, 
          position: _position, 
          polylines: _polylines,);
        break;

      case GeoEvent.nextMove:
        yield state.copyWith(
          status: Status.moving, 
          position: _position, 
          polylines: _polylines,);
        break;

      case GeoEvent.stop:
        print('stop event');
        _stopTracking();
        break;

      case GeoEvent.saveRoute:
        print('save route event');
        _saveRoute();
        break;

      case GeoEvent.error:
        print('error event: $_errorText ');
        yield state.copyWith(status: Status.error, error: _errorText);
        break;

      case GeoEvent.showSaved:
        _showSavedRoute();
        break;

      default:
        yield GeoState(status: Status.reset);
    }
  }
}



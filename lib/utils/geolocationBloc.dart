import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:maps/utils/file_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';


enum GeoEvent { start, move, nextMove, stop, reset, error, saveRoute, showSaved, deleteRoute }
enum Status { loading, showing, moving, stopped, saved, showSaved, reset, error }


class GeoState {
  final Status status;
  final Position position;
  final Map<PolylineId, Polyline>  polylines;
  final List<LatLng> route;
  final List<LatLng> oldRoute;
  final String routeName;
  final List<String> savedPaths;
  final String error;
  GeoState({ 
    this.status = Status.loading, 
    this.position, 
    this.polylines, 
    this.route, 
    this.oldRoute, 
    this.routeName,
    this.savedPaths,
    this.error 
    });

  GeoState copyWith({
    Status status,
    Position position,
    Map<PolylineId, Polyline> polylines,
    List<LatLng> route,
    List<LatLng> oldRoute,
    String routeName,
    List<String> savedPaths,
    String error,
  }) {
    return GeoState(
      status: status ?? this.status,
      position: position ?? this.position,
      polylines: polylines ?? this.polylines,
      route: route ?? this.route,
      oldRoute: oldRoute ?? this.oldRoute,
      routeName: routeName ?? this.routeName,
      savedPaths: savedPaths ?? this.savedPaths,
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
  List<LatLng> _oldRoute = List();
  String _routeName;
  List<String> _savedPaths = [];
  FileIo _fileIo = FileIo();


  setSelectedRouteName(String name) => _routeName = name;

  _getPosition() async { //get initial location
    try {
      _position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);      
      if (_position != null) {
        print(_position);  
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
            color: Colors.deepPurpleAccent[100],
            width: 6
          );
        _polylines[myPolyline.polylineId] = myPolyline;
        this.add(GeoEvent.nextMove); //keep moving
      } else {
         print('error getting updated position from stream'); 
        _errorText = 'no position available';
        this.add(GeoEvent.error);
      }
    }

  Future <bool> _saveRoute(String name) async { //save to app file storage
    try {
      print('saving route in bloc ${_myRoute.toString()} ');
      await _fileIo.writeRoute(_myRoute, name);
      return true;
    } catch(err) {  
        print('catching error saving route $err');  
        _errorText = err;
        return false;
      }
  }

  _showSavedRoute(String name) async {
    try {
      _savedPaths = await _fileIo.listDir();
      Map<String, dynamic> fileData = await _fileIo.readRoute(name);
      print('saved data in bloc? $fileData ');
      if (fileData != null && fileData['route'] != null) {
        fileData['route'].forEach((dynamic item) {
          _oldRoute.add(LatLng.fromJson(item));
         });
      }
      else throw('no route saved');
    } catch(err) {  print('catching error showing saved route: $err');  }
  }

  _deleteRoute(fileName) async {
    await _fileIo.deleteFile(fileName);
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
        print('move event');
        _startTracking();
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
        yield state.copyWith(status: Status.stopped);
        break;

      case GeoEvent.saveRoute:
        print('save route event');
        String name =_routeName ?? 'currentRoute';
        bool isSaved = await _saveRoute(name);
        yield isSaved 
          ? state.copyWith(status: Status.saved)
          : state.copyWith(status: Status.error, error: _errorText);
        break;

      case GeoEvent.showSaved:
        String name =_routeName ?? 'currentRoute';
        await _showSavedRoute(name);
        print('any files in bloc? $_savedPaths ');
        print('waiting done');
        yield state.copyWith(status: Status.showSaved, oldRoute: _oldRoute, savedPaths: _savedPaths);
        break;

      case GeoEvent.deleteRoute:
        String name =_routeName ?? 'currentRoute';
        await _deleteRoute(name);
        break;

      case GeoEvent.error:
        print('error event: $_errorText ');
        yield state.copyWith(status: Status.error, error: _errorText);
        break;

      default:
        yield GeoState(status: Status.reset);
    }
  }
}



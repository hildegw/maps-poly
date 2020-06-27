import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:maps/utils/file_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/map_review.dart';

enum GeoEvent {
  start,
  move,
  nextMove,
  stop,
  reset,
  error,
  checkOverwrite,
  saveRoute,
  showSaved,
  moveCam,
  deleteRoute,
  renameRoute
}
enum Status {
  loading,
  showing,
  moving,
  stopped,
  overwrite,
  saved,
  showSaved,
  moveCam,
  reset,
  error
}

class GeoState {
  final Status status;
  final Position position;
  final Map<PolylineId, Polyline> polylines;
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
    this.error,
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
  String _newRouteName;
  List<String> _savedPaths = [];
  FileIo _fileIo = FileIo();

  //called from track page
  setSelectedRouteName(String name) => _routeName = name;
  setNewRouteName(String name) => _newRouteName = name;

  _getPosition() async {
    //get initial location
    try {
      _position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (_position != null) {
        print(_position);
      } else
        throw ('no position available');
    } catch (err) {
      print('catching error in getPosition $err');
      _errorText = err.toString();
      this.add(GeoEvent.error);
    }
  }

  _startTracking() {
    final geolocator = Geolocator();
    final locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 5);
    _positionStream =
        geolocator.getPositionStream(locationOptions).listen(_onLocationUpdate);
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
          width: 6);
      _polylines[myPolyline.polylineId] = myPolyline;
      this.add(GeoEvent.nextMove); //keep moving
    } else {
      print('error getting updated position from stream');
      _errorText = 'no position available';
      this.add(GeoEvent.error);
    }
  }

  Future<bool> _saveRoute(String name) async {
    //save to app file storage
    try {
      print(
          'saving route with name $_routeName in bloc ${_myRoute.toString()} ');
      await _fileIo.writeRoute(_myRoute, _routeName);
      return true;
    } catch (err) {
      print('catching error saving route ${err.toString()}');
      _errorText = 'error saving route: ' + err.toString();
      this.add(GeoEvent.error);
      return false;
    }
  }

  Future<bool> _renameRoute(String newName, String name) async {
    if (newName == null) newName = name;
    print('new name? $name $newName');
    //rename existing file
    try {
      print('renaming route $_routeName in bloc with name $_newRouteName ');
      await _fileIo.renameRoute(newName, name);
      this.setSelectedRouteName(newName);
      return true;
    } catch (err) {
      print('catching error saving route ${err.toString()}');
      _errorText = 'error renaming route: ' + err.toString();
      this.add(GeoEvent.error);      
      return false;
    }
  }

  Future<bool> _checkOverwrite(String name) async {
    //save to app file storage
    try {
      //_savedPaths = await _fileIo.listDir(); //load all file paths to check if name exists
      bool overwrite = await _fileIo.fileExists(name);
      //if (_savedPaths != null && _savedPaths.length > 0) overwrite = _savedPaths.contains(name);
      print('check if track with name $name exists, in bloc $overwrite ');
      return overwrite;
    } catch (err) {
      print('catching error checking if track name exists ${err.toString()}');
      _errorText = 'error checking overwrite: ' + err.toString();
      this.add(GeoEvent.error);
      return false;
    }
  }

  _showSavedRoute(String name) async {
    try {
      _savedPaths = await _fileIo.listDir() ?? []; //load all file paths
      //if name is null, i.e. no route has been selected, show last route from list.
      if (name == null && _savedPaths.length > 0)
        name = _savedPaths[_savedPaths.length - 1];
      print('show saved route in bloc $_savedPaths with name $name');
      Map<String, dynamic> fileData = await _fileIo.readRoute(name);
      print('saved data in bloc? $fileData ');
      if (fileData != null && fileData['route'] != null) {
        _oldRoute = [];
        fileData['route'].forEach((dynamic item) {
          _oldRoute.add(LatLng.fromJson(item));
        });
        //print('oldRoute is set in bloc to show $_oldRoute');
      } else {
        _oldRoute = [];
        throw ('no route saved');
      }
    } catch (err) {
      print('catching error showing saved route: ${err.toString()}');
      _errorText = 'error showing saved route: ' + err.toString();
      this.add(GeoEvent.error);
    }
  }

  _deleteRoute(fileName) async {
    //delete selected route and update list of saved routes, show latest
    try {
      await _fileIo.deleteFile(fileName); //delete file
      _savedPaths.removeWhere(
          (path) => path == fileName); //remove file from list of paths
      print('find latest track in bloc $_savedPaths');
      String name = _savedPaths != null &&
              _savedPaths.length > 0 //set name to newest saved route
          ? _savedPaths[_savedPaths.length - 1]
          : null;
      print('find latest track in bloc $name');
      Map<String, dynamic> fileData =
          await _fileIo.readRoute(name); //show newest route
      print('saved data in bloc? $fileData ');
      if (fileData != null && fileData['route'] != null) {
        _oldRoute = [];
        fileData['route'].forEach((dynamic item) {
          _oldRoute.add(LatLng.fromJson(item));
        });
      } else {
        _oldRoute = [];
        throw ('route not found');
      }
    } catch (err) {
      print('catching error dleleting route: ${err.toString()}');
      _errorText = 'error showing deleted route: ' + err.toString();
      this.add(GeoEvent.error);    }
  }

  @override
  GeoState get initialState =>
      GeoState(status: Status.loading, polylines: _polylines);

  @override
  Stream<GeoState> mapEventToState(GeoEvent event) async* {
    switch (event) {
      case GeoEvent.start:
        await _getPosition();
        yield GeoState(
            status: Status.showing, position: _position, polylines: _polylines);
        if (_position != null)
          print('done state ${state.position} ');
        else
          print('error state ${state.error} ');
        break;

      case GeoEvent.move:
        print('move event');
        _startTracking();
        yield state.copyWith(
          status: Status.moving,
          position: _position,
          polylines: _polylines,
        );
        break;

      case GeoEvent.nextMove:
        yield state.copyWith(
          status: Status.moving,
          position: _position,
          polylines: _polylines,
        );
        break;

      case GeoEvent.stop:
        print('stop event');
        _stopTracking();
        yield state.copyWith(status: Status.stopped);
        break;

      case GeoEvent.checkOverwrite:
        print('check if track name exists, name $_routeName');
        String name = _routeName;
        bool askToOverwrite = await _checkOverwrite(name);
        print('check overwrite $askToOverwrite');
        if (askToOverwrite)
          yield state.copyWith(status: Status.overwrite);
        else
          this.add(GeoEvent.saveRoute);
        break;

      case GeoEvent.saveRoute:
        print('save route event, name $_routeName');
        String name = _routeName;
        bool isSaved = await _saveRoute(name);
        yield isSaved
            ? state.copyWith(status: Status.saved)
            : state.copyWith(status: Status.error, error: _errorText);
        break;

      case GeoEvent.renameRoute:
        print('rename route event, name $_routeName');
        String name = _routeName;
        String newName = _newRouteName;
        bool isSaved = await _renameRoute(newName, name);
        if (isSaved)
          this.add(GeoEvent.showSaved); //state.copyWith(status: Status.saved)
        else
          state.copyWith(status: Status.error, error: _errorText);
        break;

      case GeoEvent.showSaved:
        //if (_routeName == null) return;
        String name = _routeName;
        await _showSavedRoute(name);
        //print('any files in bloc? $_savedPaths ');
        print('waiting done, show saved in bloc, route name $_routeName');
        yield state.copyWith(
            status: Status.showSaved,
            oldRoute: _oldRoute,
            //routeName: _routeName, //did not work
            savedPaths: _savedPaths);
        //MapReview().moveCamera(); //move to _oldRoute does not update map :-(
        break;

      case GeoEvent.moveCam:
        yield state.copyWith(status: Status.moveCam);
        break;

      case GeoEvent.deleteRoute:
        print('delete route in bloc: $_routeName');
        if (_routeName == null) return;
        String name = _routeName;
        await _deleteRoute(name);
        print('oldRoute in bloc after delete $_oldRoute');
        yield state.copyWith(
            status: Status.showSaved,
            oldRoute: _oldRoute,
            savedPaths: _savedPaths);
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

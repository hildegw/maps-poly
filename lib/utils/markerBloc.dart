import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:maps/utils/file_io.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/map_markers.dart';

enum GeoEvent {
  start,
  latlngSelected,
  error
}

enum Status {
  loading,
  showing,
  error
}

class GeoState {
  final Status status;
  final String error;
  GeoState({
    this.status = Status.loading,
    this.error,
  });

  GeoState copyWith({
    Status status,
    String error,
  }) {
    return GeoState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class GeolocationBloc extends Bloc<GeoEvent, GeoState> {
  String _errorText = '';
  LatLng _latlng;
  Set<Marker> _markers = Set();


  //called from marker page
  setSelectedLatlng(LatLng latlng) => _latlng = latlng;
  addMarker(Marker marker) => _markers.add(marker);

  @override
  GeoState get initialState =>
      GeoState(status: Status.loading);

  @override
  Stream<GeoState> mapEventToState(GeoEvent event) async* {
    switch (event) {
      
      case GeoEvent.start:
        // await _getPosition();
        // yield GeoState(
        //     status: Status.showing, position: _position, polylines: _polylines);
        // if (_position != null)
        //   print('done state ${state.position} ');
        // else
        //   print('error state ${state.error} ');
        break;

      case GeoEvent.latlngSelected:
        print('latlng event');
        yield state.copyWith(
          status: Status.showing,
        );
        break;

      case GeoEvent.error:
        print('error event: $_errorText ');
        yield state.copyWith(status: Status.error, error: _errorText);
        break;

      default:
        yield GeoState(status: Status.showing);
    }
  }
}

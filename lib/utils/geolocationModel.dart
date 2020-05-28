import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';


class Location {
  final Coordinates coordinates;
  final int accuracy;
  Location({this.coordinates, this.accuracy});

  Location fromJson(dynamic json) {
    if (json == null) return null;
    //final Map<String, dynamic> json = jsonDecode(body);
    return Location(
      coordinates: Coordinates(
        lat: json['location']['lat'], 
        lon: json['location']['lng'],
      ), 
      accuracy: json['accuracy']
    );
  }

  String toJson(Location location) => jsonEncode(location);

  String get latLon => 'lat: ${coordinates.lat.toString()}, lon: ${coordinates.lon.toString()}';
}

class Coordinates {
  final double lat;
  final double lon;
  Coordinates({this.lat, this.lon});

  String toJson(Coordinates coordinates) => jsonEncode(coordinates);
}



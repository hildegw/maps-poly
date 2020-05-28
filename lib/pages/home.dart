import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

const mapStyle = [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8ec3b9"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1a3646"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#64779e"
      }
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#334e87"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6f9ba5"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3C7680"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#304a7d"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2c6675"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#255763"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#b0d5ce"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3a4762"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#0e1626"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4e6d70"
      }
    ]
  }
];


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  
  Completer<GoogleMapController> _mapController = Completer();
  Uint8List _carPin;
  Marker _myMarker;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  
  StreamSubscription<Position> _positionStream;
  Map<MarkerId, Marker> _markers = Map();

  @override
  void initState() {
    _loadCarPin();
    super.initState();
  }

  _loadCarPin() async {
    final byteData = await rootBundle.load('assets/icons/paw.png');
    _carPin = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(_carPin, targetHeight: 100, targetWidth: 100);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    _carPin = (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
    _startTracking();
  }

  _startTracking() {
    final geolocator = Geolocator();
    final locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _positionStream = geolocator.getPositionStream(locationOptions)
        .listen(_onLocationUpdate);
  }

  _onLocationUpdate(Position position) async {
     if (position != null) {
       LatLng latLng = LatLng(position.latitude, position.longitude);
       final pinBitmap = BitmapDescriptor.fromBytes(_carPin);
       final markerId = MarkerId('my');
       if(_myMarker == null) {
         _myMarker = Marker(
           markerId: markerId, 
           position: latLng, 
           icon: pinBitmap,
           anchor: Offset(0.5, 0.5),
           alpha: 0.2,
          );
         }
       else _myMarker = _myMarker.copyWith(positionParam: latLng);
       setState(() {
         _markers[_myMarker.markerId] = _myMarker;
       });
      
      //move map
       final GoogleMapController controller = await _mapController.future;
       controller.animateCamera(CameraUpdate.newLatLng(latLng));
       print('tracking: ' + position.latitude.toString() + ', ' + position.longitude.toString());
    }
  }

  @override
  void dispose() {
    if (_positionStream != null) _positionStream.cancel();
    super.dispose();
  }

  Future<void> _goToTheLake(LatLng pos) async {
    final CameraPosition _kLake = CameraPosition(
        bearing: 0.0,
        target: LatLng(pos.latitude, pos.longitude),
        tilt: 0.0,
        zoom: 13.0);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    print('set camera: ${pos.latitude}. ${pos.longitude} ');
  }

  _onTap(LatLng pos) { 
    print('position: ${pos.latitude}. ${pos.longitude} ');
    print('marker ${_markers.length}');
    final markerId = MarkerId('${_markers.length}');
    final marker = Marker(
      markerId: markerId, 
      position: pos,
      draggable: true,
      onDragEnd: (newPos) => _updateMarkerPosition(markerId, newPos),
    );
    setState(() {
      _markers[markerId] = marker;
    });
    _goToTheLake(pos);
  }

  _updateMarkerPosition(MarkerId markerId, LatLng newPos) {
    _markers[markerId] = _markers[markerId].copyWith(positionParam: newPos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: GoogleMap(
          //mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onTap: _onTap,//(LatLng pos) {_onTap(pos);},
          markers: Set.of(_markers.values),
          onMapCreated: (GoogleMapController controller) {
            _mapController.complete(controller);
            controller.setMapStyle(jsonEncode(mapStyle));
          },
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import './geolocationBloc.dart';



final url = 'https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyCdywm9Hw5bqu74TVvDUukJ4IYpg3_-Bzk';


class LocationApi {

  dynamic requestLocation() async {
    try {
      var response = await http.post(url, body: {});
      print(jsonDecode(response.statusCode.toString()));
      print(jsonDecode(response.body.toString()));
      return jsonDecode(response.body) ?? 'no response';
    } catch(err) { 
      print('catching error in API $err'); 
      throw(err);
    }
  }
}








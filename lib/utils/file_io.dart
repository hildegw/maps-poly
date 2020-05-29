import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';


class FileIo {


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/myRoute.txt');
  }

  writeRoute(List<LatLng> route) async {
    final String now = new DateFormat('yyyy-MM-dd hh:mm').toString();
    final file = await _localFile;
    var sink = file.openWrite();
        String json = jsonEncode({
      'fileName': 'myRoute.txt',
      'timeStamp': now,
      'route': route,
    });
    print('saved route data $json');
    sink.write(json);
    sink.close();
  }

  Future<Map<String, dynamic>> readRoute() async {
    Map<String, dynamic> fileData = {};
    String json = '';

      final file = await _localFile;
      //String contents = await file.readAsString();
      //return int.parse(contents);

      Stream<List<int>> inputStream = file.openRead();

      var lines = inputStream
        .transform(utf8.decoder)       // Decode bytes to UTF-8.
        .transform(new LineSplitter()); // Convert stream to individual lines.
      try {      
        await for (var line in lines) {
          print('$line: ${line.length} bytes');
          json += line;
        }
        fileData = jsonDecode(json);
      } catch (e) {print('inputStream catch error reading file ${e.toString()}'); }
     // print('returning fileData $fileData ');
      return fileData;
  }
}
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


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
    final file = await _localFile;
    return file.writeAsString('$route');
    //var sink = file.openWrite();
    //sink.write(route);
    //sink.close();
  }

  Future<List<LatLng>> readRoute() async {
    List<LatLng> route;
    try {
      final file = await _localFile;
      //String contents = await file.readAsString();
      //return int.parse(contents);

      Stream<List<int>> inputStream = file.openRead();

      inputStream
        .transform(utf8.decoder)       // Decode bytes to UTF-8.
        //.transform(new LineSplitter()) // Convert stream to individual lines.
        .listen((String line) {        // Process results.
            print('$line: ${line.length} bytes');
            

          },
          onDone: () { 
            print('File is now closed.'); 
          },
          onError: (e) { print(e.toString()); 
        });


    } catch (e) {
      // If encountering an error, return 0.
      return [];
    }
  }

}
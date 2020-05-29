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

  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/myMapps$fileName.txt');
  }

  Future<List<String>> listDir() async {
    List<String> dirList = [];
    final directory = await getApplicationDocumentsDirectory();
    directory.list().listen((FileSystemEntity ent) {
      dirList.add(ent.path.split('myMapps')[1].replaceAll('.txt', ''));
    });
    return dirList;
  }

  writeRoute(List<LatLng> route, String fileName) async {
    final String now = new DateFormat('yyyy-MM-dd hh:mm').toString();
    final file = await _localFile(fileName);
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

  Future<Map<String, dynamic>> readRoute(String fileName) async {
    Map<String, dynamic> fileData = {};
    String json = '';
    final file = await _localFile(fileName);

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

  Future<void> deleteFile(String fileName) async {
    final file = await _localFile(fileName);
    file.delete();
  }


}
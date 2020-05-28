import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';


class SplashPage extends StatefulWidget {
  
  const SplashPage(this._permission);
  final Permission _permission;
  
  @override
  _SplashPageState createState() => _SplashPageState(_permission);
}

class _SplashPageState extends State<SplashPage> with WidgetsBindingObserver {
  
  _SplashPageState(this._permission);

  final Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state == AppLifecycleState.resumed) _listenForPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
    if(status == PermissionStatus.granted) Navigator.pushReplacementNamed(context, 'home');
  }


  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        title: Text(_permission.toString()),
        subtitle: Text(
          _permissionStatus.toString(),
          style: TextStyle(color: getPermissionColor()),
        ),
        trailing: IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              checkServiceStatus(context, _permission);
            }),
        onTap: () {
          requestPermission(_permission);
          print('tapped');
        },
      ),
    );
  }

  void checkServiceStatus(BuildContext context, Permission permission) async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text((await permission.status).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
    if(status == PermissionStatus.granted) Navigator.pushReplacementNamed(context, 'home');
  }
}
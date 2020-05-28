import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/geolocationModel.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/mapSample.dart';


class LocationPage extends StatefulWidget {
  
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {

  @override
  void initState() {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    geolocationBloc.add(GeoEvent.start);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);

    return BlocBuilder<GeolocationBloc, GeoState> (
        builder: (context, state) {
        return SafeArea(
            child: Scaffold(
              body: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(child: MapSample()),
                      Center(
                        child: state.status == Status.loading 
                          ? Text('loading...')
                          : state.status == Status.error
                            ? Text('error: ${state.error}')
                            : Text(state.position.toString()),
                      ),
                      FlatButton(
                        onPressed: () => geolocationBloc.add(GeoEvent.move), 
                        child: Text('start tracking'),
                        color: Colors.blueGrey,
                      ),
                      FlatButton(
                        onPressed: () => geolocationBloc.add(GeoEvent.stop), 
                        child: Text('stop tracking'),
                        color: Colors.blueGrey,
                      ),
                      FlatButton(
                        onPressed: () => geolocationBloc.add(GeoEvent.saveRoute), 
                        child: Text('save route'),
                        color: Colors.blueGrey,
                      ),
                      FlatButton(
                        onPressed: () => geolocationBloc.add(GeoEvent.showSaved), 
                        child: Text('show save'),
                        color: Colors.blueGrey,    
                      ),                  
                    ],
                  ),
                ), 
              )
          );
        });
  }
}
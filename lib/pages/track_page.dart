import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/mapSample.dart';


class TrackPage extends StatefulWidget {
  
  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {

  final _formKey = GlobalKey<FormState>();
  String _fileName;

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
        return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            
            Expanded(
              child: MapSample()
            ),
            
            Center(
              child: state.status == Status.loading 
                ? Text('loading...')
                : state.status == Status.error
                  ? Text('error: ${state.error}')
                  : Text(state.position.toString()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[  //remove_circle_outline
                
                SizedBox(width: 10),
                
                IconButton(
                  onPressed: () => geolocationBloc.add(GeoEvent.move), 
                  icon: Icon(Icons.play_circle_outline, size: 35,),
                  color: Theme.of(context).accentColor,
                ),
                IconButton(
                  onPressed: () => geolocationBloc.add(GeoEvent.stop), 
                  icon: Icon(Icons.radio_button_checked, size: 35,),
                  color: Theme.of(context).accentColor,
                ),

                SizedBox(width: 20),
                
                SizedBox(
                  height: 40,
                  width: 200,
                  child: TextFormField(
                    key: _formKey,
                    validator: (value) { 
                      if (value.isEmpty) return 'saving to current route file';
                      else return null; 
                    },
                    onFieldSubmitted: (value) => _fileName = value,
                    cursorColor: Theme.of(context).accentColor,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: 'file name',  
                      labelStyle: TextStyle(color: Theme.of(context).accentColor),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:  Theme.of(context).accentColor, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:  Theme.of(context).accentColor, width: 2.0),
                      ),                      //contentPadding: EdgeInsets.all(0),
                    ),
                  ),
                ),

                IconButton(     // save data
                  onPressed: () {
                    if (_formKey.currentState.validate()) geolocationBloc.setSelectedRouteName(_fileName);                          
                    else geolocationBloc.setSelectedRouteName('currentRoute');  //TODO set with date?
                  geolocationBloc.add(GeoEvent.saveRoute);
                  }, 
                  icon: Icon(Icons.save_alt, size: 35,),
                  color: Theme.of(context).accentColor,
                ),

                SizedBox(width: 10),

              ],
            ),

             
          ],
        ),
      );
    });
  }

}
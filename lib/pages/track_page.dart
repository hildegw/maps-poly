import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/map_track.dart';


class TrackPage extends StatefulWidget {
  
  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  String _fileName;

  AnimationController animC;
  var buttonAnim;

  @override
  void initState() {
    animC = AnimationController(duration: Duration(seconds: 5), vsync: this);
    buttonAnim = Tween(begin: .7, end: 1)
      .animate(CurvedAnimation(parent: animC, curve: Curves.easeInOutSine))
      ..addListener(() {setState() {}});
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    geolocationBloc.add(GeoEvent.start);
    super.initState();
  }

 _startStopTracker(bloc) {
   if (bloc.state.status == Status.moving) bloc.add(GeoEvent.stop);
   else bloc.add(GeoEvent.move);
 }


 @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    
    return BlocBuilder<GeolocationBloc, GeoState> (
        builder: (context, state) {
        return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(

          children: <Widget>[
            
            MapTrack(),
            
            Positioned(
              left: 10,
              top:  10,
              child: Container(
                width: 270,
                padding: EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).buttonColor,
                ),
                child: state.status == Status.loading 
                  ? Text(
                      'loading...', 
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.center,
                    )
                  : state.status == Status.error
                    ? Text(
                        'error: ${state.error}', 
                        style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,                      
                      )
                    : Text(
                        state.position.toString(), 
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            
            Positioned(
              left: 30,
              bottom:  45,              
              child: Container(
                padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).buttonColor,
                ),                
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[  //remove_circle_outline
                                      
                    IconButton(
                      onPressed: () => _startStopTracker(geolocationBloc), 
                      icon: state.status == Status.moving
                        ? Icon(Icons.radio_button_checked, size: 35 * buttonAnim.value,)
                        : Icon(Icons.radio_button_unchecked, size: 35,),
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
                        style: Theme.of(context).textTheme.headline2,
                        decoration: InputDecoration(
                          labelText: 'file name',  
                          labelStyle: Theme.of(context).textTheme.subtitle1,
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
              ),
            ),

             
          ],
        ),
      );
    });
  }

}
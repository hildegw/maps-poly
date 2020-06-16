import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/map_track.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../utils/dialogs.dart';


class TrackPage extends StatefulWidget {
  
  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> with SingleTickerProviderStateMixin {


//TODO save with date?

  final _formKey = GlobalKey<FormState>();
  String _fileName;

  AnimationController animC;
  var buttonAnim;

  @override
  void initState() {
    animC = AnimationController(duration: Duration(seconds: 1), vsync: this);
    final CurvedAnimation curve = CurvedAnimation(parent: animC, curve: Curves.easeInOut);
    buttonAnim = Tween(begin: .9, end: 1)
      .animate(curve)  
      ..addListener(() {setState() {}});
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    geolocationBloc.add(GeoEvent.start);
    super.initState();
  }

 _startStopTracker(bloc) {
   if (bloc.state.status == Status.moving) {
      animC.stop();
      bloc.add(GeoEvent.stop);
    } else {
      buttonAnim.addStatusListener((status) {
        if (status == AnimationStatus.completed) animC.reverse();
        else if (status == AnimationStatus.dismissed) animC.forward();
        setState(() {});
      });
      animC.forward();
      bloc.add(GeoEvent.move);
    }
 }

  overwriteDialog(context, geolocationBloc) {
    Dialogs.alert(context, 
      title: "Overwrite Track", 
      subtitle: "The filename already exists. Do you want to overwrite?", 
      confirm: "CONFIRM",
      onConfirm: () { geolocationBloc.add(GeoEvent.saveRoute); }
    );                         
  }


  @override
  void dispose() {
    animC.dispose();
    super.dispose();
  }


 @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
   // if (geolocationBloc.state.status == Status.overwrite) 
     Future.delayed(Duration.zero, () => overwriteDialog(context, geolocationBloc)); // import 'dart:async';

    return BlocBuilder<GeolocationBloc, GeoState> (
      builder: (context, state) {
      print('track page bloc builder state status ${state.status} ');

      return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: <Widget>[
            
            MapTrack(),
          
            Positioned( //Lat Lon info top 
              left: 10,
              top:  10,
              child: Container(
                width: 270,
                padding: EdgeInsets.only(top: 8, bottom: 8),
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
            
            Positioned(  //start stop button
              left: 30,
              bottom: 30,              
              child: Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).buttonColor,
                ),                
                child: IconButton(
                      onPressed: () => _startStopTracker(geolocationBloc), 
                      icon: state.status == Status.moving
                        ? Icon(Icons.radio_button_checked, size: 40.0 * buttonAnim.value,)
                        : Transform.rotate(
                            angle: -math.pi/2,
                            child: Icon(Icons.play_circle_outline, size: 45,)
                          ),
                      color: Theme.of(context).accentColor,
                      padding: EdgeInsets.only(bottom: 0),
                    ),
              )
            ),

            state.status == Status.stopped //show file saving box
            ? Positioned(
              left: 90,
              bottom: 15,              
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 3, top: 0, bottom: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).buttonColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[  //remove_circle_outline                                   

                    SizedBox(width: 5, height: 50,),

                    Material(  // save track icon
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.transparent,
                      child: InkWell(     
                        onTap: () {
                          String now = DateFormat.yMMMd().add_Hm().format(DateTime.now());
                          //print('on tap track page $_fileName or $now');
                          //print('on tap track page ${_formKey.currentState.validate()}');
                          _fileName = _formKey.currentState.validate() ? _fileName : now;                          
                          geolocationBloc.setSelectedRouteName(_fileName);  
                          //geolocationBloc.add(GeoEvent.checkOverwrite);
                          geolocationBloc.add(GeoEvent.saveRoute);
                        }, 
                        child: Icon(Icons.save_alt, size: 30, color: Theme.of(context).accentColor,),
                        splashColor: Theme.of(context).cardColor,
                      ),
                    ),

                    SizedBox(width: 10, height: 50,),

                    SizedBox(
                      height: 35,
                      width: 160,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: (value) { 
                            if (value.isEmpty || value == null) return 'saving date'; // 'saving to current route file';
                            else return null; 
                          },
                          onChanged: (value) => _fileName = value,
                          onFieldSubmitted: (value) => _fileName = value,
                          cursorColor: Theme.of(context).accentColor,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline2,
                          decoration: InputDecoration(
                            labelText: 'add track name',  
                            labelStyle: Theme.of(context).textTheme.subtitle1,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color:  Theme.of(context).accentColor, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color:  Theme.of(context).accentColor, width: 2.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 5,),



                    SizedBox(width: 10),
                  ],
                ),
              ),
            ) : Container(),

            state.status == Status.saved //show file saving result
            ? Positioned(
              left: 90,
              bottom: 15,                  
              child: Container(
                width: 226,
                height: 50,
                padding: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).buttonColor,
                ),
                child: Text(
                        'Your track was saved.', 
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.center,
                      ),
              ),
            ) : Container(),



             
          ],
        ),
      );
    });
  }

}
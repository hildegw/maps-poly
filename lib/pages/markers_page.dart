import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/map_markers.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../utils/dialogs.dart';


class MarkersPage extends StatefulWidget {
  
  @override
  _MarkersPageState createState() => _MarkersPageState();
}

class _MarkersPageState extends State<MarkersPage> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  String _fileName;


  @override
  void initState() {
    super.initState();
  }


  infoDialog(context, geolocationBloc) {
    Dialogs.info(context, 
      subtitle: geolocationBloc.state.error, 
    );                         
  }


 @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
   
    return BlocBuilder<GeolocationBloc, GeoState> (
      builder: (context, state) {

      if (state.status == Status.error) 
        Future.delayed(Duration.zero, () => infoDialog(context, geolocationBloc)); 


      return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: <Widget>[
            
            MapMarkers(),
          
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
                  ? Text('loading...', 
                      style: Theme.of(context).textTheme.headline2,
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
                      onPressed: () => {}, 
                      icon: Icon(Icons.radio_button_checked, size: 40.0,),
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
                          _fileName = _formKey.currentState.validate() ? _fileName : now;                          
                          geolocationBloc.setSelectedRouteName(_fileName);  
                          geolocationBloc.add(GeoEvent.checkOverwrite);
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
                            labelText: 'search',  
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

                
          ],
        ),
      );
    });
  }

}
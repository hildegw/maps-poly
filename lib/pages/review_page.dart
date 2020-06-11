import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/map_review.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';


extension Precision on double {
    double toPrecision(int fractionDigits) {
        double mod = math.pow(10.0, fractionDigits.toDouble());
        return ((this * mod).round().toDouble() / mod);
    }
}


class ReviewPage extends StatefulWidget {
  
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {

  final _formKey = GlobalKey<FormState>();
  List<LatLng> _oldRoute = List();
  String _selectedRouteName;
  bool _openTrackList = false;
  bool _openEdit = false;
  String _fileName;

  @override
  void initState() {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    //geolocationBloc.setSelectedRouteName('TODO');
    geolocationBloc.add(GeoEvent.showSaved);
    super.initState();
  }


  String posString(state)  {
    _oldRoute =  state.oldRoute;
    return _oldRoute != null && _oldRoute.length > 0
      ? Position(
        latitude: _oldRoute[_oldRoute.length-1].latitude.toPrecision(6), 
        longitude: _oldRoute[_oldRoute.length-1].longitude.toPrecision(6)
      ).toString() : state.position.toString();
  }


  Widget FilesDropDown(context, state, geolocationBloc) {
    //preset drop down with last value
    if (_selectedRouteName == null && state.status == Status.showSaved && state.savedPaths.length > 0) 
        _selectedRouteName = state.savedPaths[state.savedPaths.length-1];
    print('open track list? $_openTrackList ');
    
    return _openTrackList //&& state.status == Status.showSaved 
      ? Container(      //closes list
          width: 253,
          height: state.savedPaths.length.toDouble() * 30,
          padding: EdgeInsets.only(left: 24.0, right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).buttonColor,
          ),   
          child: ListView.builder(
            itemCount: state.savedPaths.length,
            itemBuilder: (BuildContext context, int index) {
              print('list with items in review drop down ${state.savedPaths[index]} ');
              return GestureDetector(
                  onTap: () => setState(() { 
                    _selectedRouteName = state.savedPaths[index]; 
                    _openTrackList = !_openTrackList;
                    geolocationBloc.setSelectedRouteName(_selectedRouteName);
                    geolocationBloc.add(GeoEvent.showSaved);                  
                    }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                          state.savedPaths[index] ?? 'no tracks available',
                          style: Theme.of(context).textTheme.headline2,
                          textAlign: TextAlign.center,
                        ),
                  ),
              );
            }
          )
        )
      : GestureDetector(  //closed drop down clickable area
          onTap: () => setState(() { _openEdit = !_openEdit; }),
          child: Container(      //closes list
            height: 50,
            width: 253,
            padding: EdgeInsets.only(left: 24.0, right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).buttonColor,
            ),   
            child:  Center(
              child: Text(
                  _selectedRouteName ?? 'please select a track',
                  style: Theme.of(context).textTheme.headline2,
                  textAlign: TextAlign.center,
                ),
            ),
          ),
        );
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
              
              MapReview(), // map or spinner
              
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
                  child: Text(
                    posString(state),
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

//DropDown
              _openEdit ? Container() 
              : Positioned(  //drop down for files
                  left: 90,
                  bottom: 15,                   
                    child: FilesDropDown(context, state, geolocationBloc),
                ),

//Open drop down button
              Positioned(  
                left: 30,
                bottom: 30,              
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).buttonColor,
                  ),                
                  child: Icon(Icons.radio_button_unchecked, size: 46.0, color: Theme.of(context).accentColor,),
                )
              ),
              Positioned(  //edit button ring and background
                left: 34,
                bottom: 33,              
                    child: IconButton(
                      onPressed: () => setState(() { _openTrackList = !_openTrackList; }), //geolocationBloc.add(GeoEvent.deleteRoute), 
                      icon:Icon(Icons.arrow_drop_down, size: 23.0),
                      color: Theme.of(context).accentColor,
                      padding: EdgeInsets.only(bottom: 0),
                    ),
              ),

//name edit & delete form field
              _openEdit  //show track edit & delete field
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

                        Material(  // save new track name TODO
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.transparent,
                          child: InkWell(     
                            onTap: () {
                              //TODO
                              setState(() { _openEdit = !_openEdit; });
                              //_fileName = _formKey.currentState.validate() ? _fileName : null;                          
                            }, 
                            child: Icon(Icons.save_alt, size: 30, color: Theme.of(context).accentColor,),
                            splashColor: Theme.of(context).cardColor,
                          ),
                        ),

                        SizedBox(width: 3, height: 50,),

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
                                labelText: _selectedRouteName,  
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
                        
                        SizedBox(width: 7),

                        Material(  // delete track icon
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.transparent,
                          child: InkWell(     
                            onTap: () {
                              String now = DateFormat.yMMMd().add_Hm().format(DateTime.now());
                              _fileName = _formKey.currentState.validate() ? _fileName : now;                          
                              geolocationBloc.add(GeoEvent.deleteRoute);
                            }, 
                            child: Icon(Icons.delete_outline, size: 30, color: Theme.of(context).accentColor,),
                            splashColor: Theme.of(context).cardColor,
                          ),
                        ),

                        SizedBox(width: 7),

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
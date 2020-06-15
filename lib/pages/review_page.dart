import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/map_review.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../utils/dialogs.dart';


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

  deleteDialog(context, geolocationBloc ) {
    Dialogs.alert(context, 
      title: "Delete Track", 
      subtitle: "Are you sure?", 
      confirm: "CONFIRM",
      onConfirm: () {
          geolocationBloc.add(GeoEvent.deleteRoute);
          _selectedRouteName = null; //reset selected route name
      }
    );                         
  }


  Widget FilesDropDown(context, state, geolocationBloc) {
    print(state.savedPaths.length);
    return  state.savedPaths.length > 0
      ? Container(      //show list of all tracks
          width: 215,
          height: math.min(350, state.savedPaths.length.toDouble() * 32),
          padding: EdgeInsets.only(left: 24.0, right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
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
                      padding: index == 0 
                        ? EdgeInsets.only(top: 12.0, bottom: 7)
                        : EdgeInsets.symmetric(vertical: 7.0),
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
        : Container(      //show list of all tracks
            width: 215,
            height: 40,
            padding: EdgeInsets.only(left: 24.0, right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).buttonColor,
            ),   
            child: Center(
              child: Text(
                'no tracks saved',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
        );
  }




  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);

    return BlocBuilder<GeolocationBloc, GeoState> (
        builder: (context, state) {
        //preset text edit with last value
        if (_selectedRouteName == null && state.status == Status.showSaved && state.savedPaths.length > 0) 
            _selectedRouteName = state.savedPaths[state.savedPaths.length-1];
        //set _oldRoute in Bloc
        geolocationBloc.setSelectedRouteName(_selectedRouteName);
        print('open track list? $_openTrackList ');

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
              _openTrackList
                ? Positioned(  //drop down for files
                    left: 45,
                    bottom: 75,                   
                      child: FilesDropDown(context, state, geolocationBloc),
                  ) : Container(),

//selected track box
              Positioned(
                left: 90,
                bottom: 15,  
                child: GestureDetector(  
                  onTap: () => setState(() { _openEdit = !_openEdit; }),
                  child: Container(      
                    height: 50,
                    width: 215,
                    padding: EdgeInsets.only(left: 24.0, right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).buttonColor,
                    ),   
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                            _selectedRouteName ?? 'please select a track',
                            style: Theme.of(context).textTheme.headline2.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        Icon(Icons.edit, size: 25.0, color: Theme.of(context).accentColor,),
                      ],
                    ),
                  ),
                ),
            ),


//Open drop down button, icon and ring
              Positioned(  
                left: 30,
                bottom: 40,              
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).buttonColor,
                  ),                
                  child: Icon(Icons.radio_button_unchecked, size: 46.0, color: Theme.of(context).accentColor,),
                )
              ),
              Positioned(  
                left: 33,
                bottom: 43,              
                    child: IconButton(
                      onPressed: () => setState(() { _openTrackList = !_openTrackList; }),
                      icon: _openTrackList 
                        ? Icon(Icons.arrow_drop_down, size: 40.0)
                        : Icon(Icons.arrow_drop_up, size: 40.0),
                      color: Theme.of(context).accentColor,
                      padding: EdgeInsets.only(bottom: 0),
                    ),
              ),

//delete track
              Positioned(  
                left: 65,
                bottom: 8,              
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).buttonColor,
                  ),
                  child: Icon(Icons.radio_button_unchecked, size: 30.0, color: Theme.of(context).accentColor,),
                )
              ),
              Positioned(  
                left: 58,
                bottom: 2,              
                    child: IconButton(
                      onPressed: () { deleteDialog(context, geolocationBloc); },
                      icon: Icon(Icons.delete_outline, size: 18.0),
                      color: Theme.of(context).accentColor,
                      padding: EdgeInsets.only(bottom: 0),
                    ),
              ),
              
          
//edit form field
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

                        SizedBox(width: 10, height: 50,), //defines background height

                        SizedBox(
                          height: 35,
                          width: 155,
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (value) { 
                                if (value.isEmpty || value == null) return 'saving date'; // 'saving to current route file';
                                else return null; 
                              },
                              initialValue: _selectedRouteName,
                              onChanged: (value) => _fileName = value,
                              onFieldSubmitted: (value) => _fileName = value,
                              cursorColor: Theme.of(context).accentColor,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline2,
                              decoration: InputDecoration(
                                //labelText: _selectedRouteName,  
                                //labelStyle: Theme.of(context).textTheme.subtitle1,
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
                        
                        SizedBox(width: 5),

                        Column(
                          children: <Widget>[
                            Material(  // save new track name 
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.transparent,
                              child: InkWell(     
                                onTap: () {
                                  //TODO
                                  setState(() { 
                                    _openEdit = !_openEdit; 
                                    //_openTrackList = false;
                                  });
                                  //_fileName = _formKey.currentState.validate() ? _fileName : null;                          
                                }, 
                                child: Icon(Icons.check_circle_outline, size: 20, color: Theme.of(context).accentColor,),
                                splashColor: Theme.of(context).cardColor,
                              ),
                            ),

                            Material(  // close edit track x with circle
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.transparent,
                              child: InkWell(     
                                onTap: () { setState(() { 
                                  _openEdit = false; 
                                  //_openTrackList = false;
                                });}, 
                                child: Stack(
                                  children: <Widget>[
                                    Positioned(
                                      top: 2,
                                      left: 2,
                                      child: Icon(Icons.close, size: 16, color: Theme.of(context).accentColor,)
                                    ),
                                    Icon(Icons.radio_button_unchecked, size: 20.0, color: Theme.of(context).accentColor,),
                                  ],
                                ),
                                splashColor: Theme.of(context).cardColor,
                              ),
                            ),                            
                          ],
                        ),


                        SizedBox(width: 14),

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
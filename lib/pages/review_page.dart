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
    print('dropdown value in review page $_selectedRouteName ');
    print('saved paths ${state.savedPaths}');
    //preset drop down with last value
    if (_selectedRouteName == null && state.status == Status.showSaved && state.savedPaths.length > 0) 
        _selectedRouteName = state.savedPaths[state.savedPaths.length-1];

    return Container(
      //height: 40,
      width: 200,
      padding: EdgeInsets.only(left: 24.0, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Theme.of(context).buttonColor,
      ),   
      child: DropdownButton<String>(
        value: _selectedRouteName,
        icon: Icon(Icons.arrow_downward),
        isExpanded: true,
        iconSize: 24,
        iconEnabledColor: Theme.of(context).accentColor,
        elevation: 16,
        style: Theme.of(context).textTheme.headline2,
        onChanged: (String newValue) { 
          geolocationBloc.setSelectedRouteName(newValue);
          geolocationBloc.add(GeoEvent.showSaved);
          setState(() { _selectedRouteName = newValue; });  //sets selected drop down value
        },
        items: state.status == Status.showSaved 
          ? state.savedPaths.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList() : [],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final geolocationBloc = BlocProvider.of<GeolocationBloc>(context);
    print('show edit? $_openEdit');

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
              _openEdit ? Container() : Positioned(  //drop down for files
              left: 90,
              bottom: 15,                   
                child: FilesDropDown(context, state, geolocationBloc),
              ),
//Edit button
              Positioned(  //edit button
                left: 30,
                bottom: 30,              
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).buttonColor,
                  ),                
                  child: IconButton(
                      onPressed: () => setState(() { _openEdit = true; }), //geolocationBloc.add(GeoEvent.deleteRoute), 
                      icon:Icon(Icons.edit, size: 23.0),
                      color: Theme.of(context).accentColor,
                      padding: EdgeInsets.only(bottom: 0),
                    ),
                )
              ),
              Positioned(  //edit button ring
                left: 35,
                bottom: 35,              
                child: Icon(Icons.radio_button_unchecked, size: 46.0, color: Theme.of(context).accentColor,),
              ),

//name edit & delete
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



          
          ],
        ),
      );
    });
  }
}
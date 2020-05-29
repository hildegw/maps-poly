import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/geolocationBloc.dart';
import '../widgets/map_review.dart';


class ReviewPage extends StatefulWidget {
  
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {



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
                      Flexible(child: MapReview()),
                      
                      Center(child: Text(state.position.toString()),),
                      Center(child: Text(state.savedPaths.toString()),),

                      FlatButton(
                        onPressed: () => geolocationBloc.add(GeoEvent.deleteRoute), 
                        child: Text('delete route'),
                        color: Colors.blueGrey,
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        }, 
                        child: Text('go back'),
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
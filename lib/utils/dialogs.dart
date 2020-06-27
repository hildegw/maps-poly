import 'package:flutter/material.dart';



class Dialogs {

  static Future<void> alert(
    BuildContext context,
    {
      String title,
      String subtitle,
      String confirm,
      VoidCallback onConfirm
    }
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.headline2,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
              Text(subtitle, style: Theme.of(context).textTheme.subtitle1,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(confirm, style: Theme.of(context).textTheme.headline2,),
              onPressed: () { 
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('CANCEL', style: Theme.of(context).textTheme.subtitle2,),
              onPressed: () { Navigator.of(context).pop(); },
            ),
          ],
        );
      },
    );
  }


static Future<void> info(
    BuildContext context,
    {
      String subtitle,
    }
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('An error occured.', style: Theme.of(context).textTheme.headline2,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
              Text(subtitle, style: Theme.of(context).textTheme.subtitle1,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('BACK', style: Theme.of(context).textTheme.subtitle2,),
              onPressed: () { Navigator.of(context).pop(); },
            ),
          ],
        );
      },
    );
  }

}
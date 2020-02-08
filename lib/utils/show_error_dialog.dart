import 'package:flutter/material.dart';

void showErrorDialog({
  BuildContext context,
  String title = '앗!',
  String message,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text("앗!"),
        content: new Text(message),
        actions: <Widget>[
          new FlatButton(
            textColor: Colors.black,
            child: new Text("닫기"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

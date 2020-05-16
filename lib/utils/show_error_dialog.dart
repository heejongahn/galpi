import 'package:flutter/material.dart';

void showErrorDialog({
  BuildContext context,
  String title = '앗!',
  String message,
}) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("앗!"),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.black,
            child: const Text("닫기"),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}

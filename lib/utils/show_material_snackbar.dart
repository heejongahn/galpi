import 'package:flutter/material.dart';

void showMaterialSnackbar(BuildContext context, String message) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}

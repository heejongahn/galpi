import 'package:flutter/material.dart';

typedef Future<void> OnConfirm(String value);
typedef void OnClose();

class InputDialog extends StatefulWidget {
  final String initialValue;

  @required
  final String title;

  final String message;

  @required
  final OnConfirm onConfirm;

  @required
  final OnClose onClose;

  InputDialog({
    Key key,
    this.initialValue = '',
    this.title,
    this.message = '',
    this.onConfirm,
    this.onClose,
  }) : super(key: key);

  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  String _value = '';
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.message),
            TextField(
              controller: _controller,
              onChanged: (newValue) {
                setState(() {
                  _value = newValue;
                });
              },
            )
          ],
        ),
        actions: [
          FlatButton(
            child: Text('취소'),
            onPressed: widget.onClose,
          ),
          FlatButton(
            child: Text('확인'),
            onPressed: onConfirm,
          ),
        ]);
  }

  void onConfirm() async {
    await widget.onConfirm(_value);
    widget.onClose();
  }
}

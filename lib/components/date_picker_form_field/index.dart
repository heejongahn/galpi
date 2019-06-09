import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef void OnSaved(DateTime date);

final formatter = DateFormat('yyyy-MM-dd');

class DatePickerFormField extends StatefulWidget {
  final OnSaved onSaved;
  final String label;
  final DateTime initialDate;

  DatePickerFormField({
    Key key,
    this.onSaved,
    this.label,
    this.initialDate,
  }) : super(key: key);

  _DatePickerFormFieldState createState() =>
      _DatePickerFormFieldState(initialDate);
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  DateTime date;

  _DatePickerFormFieldState(DateTime initialDate) {
    date = initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: GestureDetector(
        child: FormField(
          onSaved: _onSaved,
          builder: (FormFieldState state) {
            return Container(
              padding: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1, color: Colors.black12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildLabel(context),
                  buildDateText(),
                ],
              ),
            );
          },
        ),
        onTap: _onTap,
      ),
    );
  }

  Text buildDateText() {
    return Text(date != null ? formatter.format(date) : '날짜 없음',
        style: TextStyle(fontSize: 17));
  }

  Text buildLabel(BuildContext context) {
    return Text(
      widget.label,
      style: Theme.of(context).textTheme.caption,
    );
  }

  _onSaved(_) {
    widget.onSaved(date);
  }

  _onTap() async {
    final selectedDate = await showDatePicker(
        locale: Locale('ko'),
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(2019),
        lastDate: DateTime(2099));

    setState(() {
      if (selectedDate != null) {
        date = selectedDate;
      }
    });
  }
}

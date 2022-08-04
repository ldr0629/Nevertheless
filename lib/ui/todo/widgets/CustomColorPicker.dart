import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

typedef OnColorSelected = Function(Color color);


class CustomColorPicker extends AlertDialog {

  const CustomColorPicker({this.bgColor, this.textColor,
    required this.onColorSelected, required this.pickerColor });

  final Color pickerColor;
  final Color? bgColor;
  final Color? textColor;
  final OnColorSelected onColorSelected;

  @override
  Widget build(BuildContext context) {
    Color pickedColor = pickerColor;
    return AlertDialog(
      scrollable: true,
      backgroundColor: bgColor,
      title: Text('Palette', style: TextStyle(color: textColor)),
      content: SingleChildScrollView(
        child: ColorPicker(
          enableAlpha: false,
          pickerColor: pickedColor,
          onColorChanged: (color) {
            pickedColor = color;
          },
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(
                  '확인', style: TextStyle(fontSize: 16, color: textColor),),
                onPressed: () {
                  onColorSelected(pickedColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
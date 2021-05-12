import '../config/palette.dart';
import 'package:flutter/material.dart';

class Dropdownfield extends StatefulWidget {
  final List<String> dropdownItems;
  final Function selectedAuthority;
  Dropdownfield(this.dropdownItems, {this.selectedAuthority});
  @override
  _DropdownfieldState createState() => _DropdownfieldState();
}

class _DropdownfieldState extends State<Dropdownfield> {
  dynamic dropdownBuilder(List<String> items) {
    return items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Select Concerned Authority',
        labelStyle: TextStyle(fontSize: 12),
        prefixIcon: Icon(
          Icons.person,
          color: Palette.iconColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Palette.textColor1),
          borderRadius: BorderRadius.all(Radius.circular(22.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Palette.textColor1),
          borderRadius: BorderRadius.all(Radius.circular(22.0)),
        ),
      ),
      onChanged: (String newValue) => widget.selectedAuthority(newValue),
      items: dropdownBuilder(widget.dropdownItems),
    );
  }
}

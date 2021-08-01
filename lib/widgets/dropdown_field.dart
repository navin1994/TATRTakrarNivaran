import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';
import '../config/palette.dart';

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
        labelText: LocaleKeys.select_concerned.tr(),
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

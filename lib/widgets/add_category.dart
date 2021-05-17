import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _categoryLeve = ["P1", "P2", "P3"];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 4,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                LocaleKeys.complaint_category_form.tr(),
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: LocaleKeys.complaint_category.tr()),
                onSaved: (userType) {},
                validator: (value) {
                  if (value.isEmpty) {
                    return LocaleKeys.please_category_of_complaint.tr();
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    hintText: LocaleKeys.select_category_level.tr()),
                onSaved: (designation) {},
                validator: (value) {
                  if (value == null) {
                    return LocaleKeys.please_select_category_level.tr();
                  }
                  return null;
                },
                onChanged: (String newValue) {},
                items: _categoryLeve
                    ?.map(
                      (level) => new DropdownMenuItem<String>(
                        child: new Text(level),
                        value: level,
                      ),
                    )
                    ?.toList(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink, // background
                  onPrimary: Colors.white, // foreground
                ),
                child: Text(
                  LocaleKeys.add_category.tr(),
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';

class AddUserType extends StatefulWidget {
  @override
  _AddUserTypeState createState() => _AddUserTypeState();
}

class _AddUserTypeState extends State<AddUserType> {
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
                LocaleKeys.user_type_form.tr(),
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration:
                    InputDecoration(labelText: LocaleKeys.user_type.tr()),
                onSaved: (userType) {},
                validator: (value) {
                  if (value.isEmpty) {
                    return LocaleKeys.please_enter_user_type.tr();
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
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration:
                    InputDecoration(labelText: LocaleKeys.user_level.tr()),
                onSaved: (userType) {},
                validator: (value) {
                  if (value.isEmpty) {
                    return LocaleKeys.please_enter_user_level.tr();
                  }
                  return null;
                },
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
                  LocaleKeys.submit.tr(),
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

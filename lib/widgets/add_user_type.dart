import 'package:flutter/material.dart';

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
                'User Type Form',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "User type"),
                onSaved: (userType) {},
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter user type';
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
                decoration: InputDecoration(labelText: "User level"),
                onSaved: (userType) {},
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter user level';
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
                  'Submit',
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

import 'package:flutter/material.dart';

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
                'Complaint Category Form',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Complaint Category"),
                onSaved: (userType) {},
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please category of complaint.';
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
                decoration: InputDecoration(hintText: 'Select Category Level'),
                onSaved: (designation) {},
                validator: (value) {
                  if (value == null) {
                    return 'Please select category level.';
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
                  'Add Category',
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

import 'package:complaint_management/models/division.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/divisions.dart';

class AddRange extends StatefulWidget {
  @override
  _AddRangeState createState() => _AddRangeState();
}

class _AddRangeState extends State<AddRange> {
  Division selDiv;
  var _isLoading = false;
  var _init = true;

  @override
  void didChangeDependencies() {
    // if (!_init) {
    //   return;
    // }
    // // TODO: implement didChangeDependencies
    // setState(() {
    //   _isLoading = true;
    // });
    // Provider.of<Divisions>(context, listen: false)
    //     .fetchAndSetDivisons()
    //     .then((_) {
    //   setState(() {
    //     _init = false;
    //     _isLoading = false;
    //   });
    // });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Division> _divisions = Provider.of<Divisions>(context).divisions;
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
                'Add Range Form',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Range Name"),
                onSaved: (userType) {},
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter range name.';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _isLoading
                ? CircularProgressIndicator()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonFormField<Division>(
                      value: selDiv,
                      decoration: InputDecoration(hintText: 'Select Division'),
                      onSaved: (designation) {},
                      validator: (value) {
                        if (value == null) {
                          return 'Please select division.';
                        }
                        return null;
                      },
                      onChanged: (newValue) {
                        selDiv = newValue;
                      },
                      items: _divisions
                          .map(
                            (div) => new DropdownMenuItem(
                              child: new Text(div.text),
                              value: div,
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
                  'Add Range',
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

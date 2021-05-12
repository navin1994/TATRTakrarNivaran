import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/include_unser.dart';

class SearchBox extends StatefulWidget {
  final Function searchFeature;
  SearchBox(this.searchFeature);
  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _searchText = new TextEditingController();
  String inclUndr =
      "R"; // default Search within complaints raised by searching user
  final List<IncludeUnder> _dropdown = [
    IncludeUnder(text: "Alloted to me", value: "A"),
    IncludeUnder(text: "My complaints", value: "R"),
    IncludeUnder(text: "Under my authority", value: "U"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchText,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      hintText: 'Search by complaint number',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 12,
                    primary: Colors.red, // background
                    onPrimary: Colors.white, // foreground
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  icon: Icon(Icons.cancel_outlined),
                  label: Text('Clear'),
                  onPressed: () => {_searchText.clear()},
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: new Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.blue.shade200,
                    ),
                    child: DropdownButtonFormField<String>(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      isExpanded: true,
                      value: inclUndr,
                      decoration: InputDecoration(
                        labelText: "Search Under",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(35.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(35.0)),
                        ),
                        contentPadding: EdgeInsets.all(10),
                        hintStyle: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          inclUndr = value;
                        });
                      },
                      items: _dropdown
                          ?.map(
                            (elem) => new DropdownMenuItem(
                              child: new Text(elem.text),
                              value: elem.value,
                            ),
                          )
                          ?.toList(),
                    ),
                  ),
                ),
                Flexible(
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 12,
                        primary: Colors.amber, // background
                        onPrimary: Colors.white, // foreground
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      icon: Icon(Icons.search),
                      label: Text('Search'),
                      onPressed: () => {
                            if (_searchText.text == "" ||
                                _searchText.text == null)
                              {
                                widget.searchFeature(null, inclUndr),
                              }
                            else
                              {
                                widget.searchFeature(
                                    int.parse(_searchText.text), inclUndr),
                              }
                          }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

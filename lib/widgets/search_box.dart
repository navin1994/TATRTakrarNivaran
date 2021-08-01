import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';
import '../models/include_unser.dart';

class SearchBox extends StatefulWidget {
  final Function searchFeature;
  final Function dropdownChangeFilter;
  final String srchUnder;
  SearchBox(this.searchFeature, this.srchUnder, this.dropdownChangeFilter);
  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _searchText = new TextEditingController();

  final List<IncludeUnder> _dropdown = [
    IncludeUnder(text: LocaleKeys.alloted_to_me.tr(), value: "A"),
    IncludeUnder(text: LocaleKeys.my_complaints.tr(), value: "R"),
    IncludeUnder(text: LocaleKeys.under_my_authority.tr(), value: "U"),
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
                      // icon: Icon(
                      //   Icons.search,
                      //   color: Colors.white,
                      // ),
                      hintText: LocaleKeys.search_by_complaint.tr(),
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: () => {
                    if (_searchText.text == "" || _searchText.text == null)
                      {
                        widget.searchFeature(null, widget.srchUnder),
                      }
                    else
                      {
                        widget.searchFeature(
                            _searchText.text, widget.srchUnder),
                      }
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: new Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.amber[900],
                    ),
                    child: DropdownButtonFormField<String>(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      isExpanded: true,
                      value: widget.srchUnder,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.search_under.tr(),
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
                        widget.dropdownChangeFilter(value);
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
                  child: IconButton(
                      color: Colors.red,
                      iconSize: 30,
                      icon: Icon(Icons.cancel_outlined),
                      onPressed: () {
                        _searchText.clear();
                        widget.dropdownChangeFilter(widget.srchUnder);
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

import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import '../models/category.dart';
import '../config/env.dart';

class Categories with ChangeNotifier {
  final String api = Environment.url;
  List<Category> _categories = [];

  List<Category> get categories {
    return [..._categories];
  }

  int uid;
  int clntId;
  String name;
  Categories(this.uid, this.clntId, this.name, this._categories);
  Future fetchAndSetCategories() async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "act": "getcmptyphd",
          "clntId": clntId,
          "uid": uid,
          "name": name,
        }),
      );
      List<Category> loadedCategories = [];
      final categoriesData = json.decode(response.body);
      if (categoriesData['Result'] == "OK") {
        final records = categoriesData['Records'] as List<dynamic>;
        loadedCategories = records
            .map(
              (category) => Category(
                hdid: category['hdid'],
                hdnm: category['hdnm'],
                hddtls: category['hddtls'],
                undhd: category['undhd'],
                undhdNm: category['undhdNm'],
                hdlvl: category['hdlvl'],
                stat: category['stat'],
                regon: category['regon'],
                regby: category['regby'],
              ),
            )
            .toList();
      } else {
        _categories = loadedCategories;
        notifyListeners();
        return categoriesData['Msg'];
      }
      _categories = loadedCategories;
      notifyListeners();
      return 0;
    } catch (error) {
      throw error;
    }
  }
}

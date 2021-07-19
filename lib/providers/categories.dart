import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../Interceptor/interceptor.dart';
import '../models/category.dart';
import '../config/env.dart';

class Categories with ChangeNotifier {
  final String api = Environment.url;
  List<Category> _categories = [];
  final http = InterceptedHttp.build(interceptors: [
    HttpInterceptor(),
  ]);

  List<Category> get categories {
    // returns the copy of _categories
    return [..._categories];
  }

  int uid;
  int clntId;
  String name;
  // Constructor to get the logged in user data from Auth provider class
  Categories(this.uid, this.clntId, this.name, this._categories);

  // fetchAndSetCategories() method fetch the complaint categories from the server
  Future fetchAndSetCategories() async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
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

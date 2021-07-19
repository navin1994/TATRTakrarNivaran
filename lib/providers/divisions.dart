import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../Interceptor/interceptor.dart';
import '../models/division.dart';
import '../config/env.dart';

class Divisions with ChangeNotifier {
  List<Division> _divisions = [];
  final String api = Environment.url;
  final http = InterceptedHttp.build(interceptors: [
    HttpInterceptor(),
  ]);

  List<Division> get divisions {
    return [..._divisions];
  }

// fetch divisions to populate in user registration form
  Future fetchAndSetDivisons() async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "act": "clntmainofchd",
          "clntId": "4G0T337M"
        }), // 4G0T337M   prod => YKV9BWUK
      );
      List<Division> loadedDivisions = [];
      final divisionData = json.decode(response.body);
      if (divisionData['Result'] == "OK") {
        final records = divisionData['Records'] as List<dynamic>;
        loadedDivisions = records
            .map((division) => Division(
                  value: division['value'],
                  text: division['text'],
                  no: division['no'],
                ))
            .toList();
      } else {
        _divisions = loadedDivisions;
        notifyListeners();
        return divisionData['Msg'];
      }
      _divisions = loadedDivisions;
      notifyListeners();
      return 0;
    } catch (error) {
      throw error;
    }
  }
}

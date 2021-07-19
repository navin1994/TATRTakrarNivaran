import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../Interceptor/interceptor.dart';
import '../models/reporting_officer.dart';
import '../config/env.dart';

class ReportingOfficers with ChangeNotifier {
  final api = Environment.url;
  List<ReportingOfficer> _reportingOfficers = [];
  final http = InterceptedHttp.build(interceptors: [
    HttpInterceptor(),
  ]);

  List<ReportingOfficer> get reportingOfficers {
    // Returns the copy of _reportingOfficers
    return [..._reportingOfficers];
  }

  // Fetches the list of reporting officers based on data of Designation Id and Office Id of user
  // which is being registered
  Future fetchAndSetReportingOfficers(int desigId, int ofcId) async {
    if (desigId == null || ofcId == null) {
      return;
    }
    var url = Uri.parse('$api/userapp/datcmplntsrvc');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "act": "getreprtngofcr",
          "desigid": desigId,
          "ofcid": ofcId,
        }),
      );
      List<ReportingOfficer> loadedReportingOfficers = [];
      final result = json.decode(response.body);
      if (result['Result'] == "OK") {
        final officers = result['dta1'] as List<dynamic>;
        loadedReportingOfficers = officers
            .map(
              (officer) => ReportingOfficer(
                value: officer['value'],
                text: officer['text'],
                no: officer['no'],
              ),
            )
            .toList();
      } else {
        return result['Result'];
      }
      _reportingOfficers = loadedReportingOfficers;
      notifyListeners();
      return;
    } catch (error) {
      throw error;
    }
  }
}

import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import '../models/reporting_officer.dart';
import '../config/env.dart';

class ReportingOfficers with ChangeNotifier {
  final api = Environment.url;
  List<ReportingOfficer> _reportingOfficers = [];

  List<ReportingOfficer> get reportingOfficers {
    return [..._reportingOfficers];
  }

  Future fetchAndSetReportingOfficers(int desigId, int ofcId) async {
    if (desigId == null || ofcId == null) {
      return;
    }
    var url = Uri.parse('$api/userapp/datcmplntsrvc');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "act": "getreprtngofcr",
          "desigid": desigId,
          "ofcid": ofcId,
        }),
      );
      List<ReportingOfficer> loadedReportingOfficers = [];
      final result = json.decode(response.body);
      print("Reporting officers from server: $result");
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
      print("Error => $error");
      throw error;
    }
  }
}

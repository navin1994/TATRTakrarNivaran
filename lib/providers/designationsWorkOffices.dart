import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../Interceptor/interceptor.dart';
import '../models/work_office.dart';
import '../models/designation.dart';
import '../config/env.dart';

class DesignationAndWorkOffices with ChangeNotifier {
  final String api = Environment.url;

  List<Designation> _designations = [];
  List<WorkOffice> _workOffices = [];
  final http = InterceptedHttp.build(interceptors: [
    HttpInterceptor(),
  ]);

  List<Designation> get designations {
    return [..._designations];
  }

  List<WorkOffice> get workOffices {
    return [..._workOffices];
  }

// fetch the designation and work offices to populate in user registration form
  Future fetchAndSetDesigAndWorkOfcs(int ofcid) async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
        body: json.encode({"act": "getregdtls", "ofcid": ofcid}),
      );
      List<Designation> loadedDesignations = [];
      List<WorkOffice> loadedWorkOffices = [];
      final result = json.decode(response.body);
      if (result['Result'] == "OK") {
        final offices = result['dta1'] as List<dynamic>;
        final designations = result['dta2'] as List<dynamic>;
        loadedWorkOffices = offices
            .map(
              (office) => WorkOffice(
                hdid: office['hdid'],
                hdnm: office['hdnm'],
                hddtls: office['hddtls'],
                undhd: office['undhd'],
                undhdNm: office['undhdNm'],
                hdlvl: office['hdlvl'],
                stat: office['stat'],
                regon: office['regon'],
                regby: office['regby'],
              ),
            )
            .toList();
        loadedDesignations = designations
            .map(
              (desig) => Designation(
                hdid: desig['hdid'],
                hdnm: desig['hdnm'],
                hddtls: desig['hddtls'],
                undhd: desig['undhd'],
                undhdNm: desig['undhdNm'],
                hdlvl: desig['hdlvl'],
                stat: desig['stat'],
                regon: desig['regon'],
                regby: desig['regon'],
              ),
            )
            .toList();
      } else {
        _designations = loadedDesignations;
        _workOffices = loadedWorkOffices;
        notifyListeners();
        return result['Msg'];
      }
      _designations = loadedDesignations;
      _workOffices = loadedWorkOffices;
      notifyListeners();
      return 0;
    } catch (error) {
      throw error;
    }
  }
}

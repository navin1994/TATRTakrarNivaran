import 'dart:convert';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import '../models/complaint_summary.dart';
import '../models/comments.dart';
import '../models/complaint.dart';
import '../config/env.dart';

class Complaints with ChangeNotifier {
  final String api = Environment.url;
  List<Complaint> _complaints = [];
  Complaint _complaint = Complaint();
  List<ComplaintSummary> _complaintSummary = [];

  int uid;
  int clntId;
  String name;

  Complaints(this.uid, this.clntId, this.name, this._complaints);

  List<Complaint> get complaints {
    return [..._complaints];
  }

  Complaint get complaint {
    return _complaint;
  }

  List<ComplaintSummary> get complaintSummary {
    return _complaintSummary;
  }

  Future<void> findById(int cmpId) async {
    _complaint = _complaints.firstWhere((comp) => comp.cmpId == cmpId);
  }

  void removeItem(int cmpId) {
    _complaints.removeWhere((cmp) => cmp.cmpId == cmpId);
    notifyListeners();
  }

  Future serachComplaint(String crit, int srcCmpno, String inclUndr) async {
    print("crit : $crit");
    print("srcCmpno : $srcCmpno");
    print("inclUndr : $inclUndr");
    var sResult;
    var url = Uri.parse("$api/userapp/cmplntmangesrvc");

    List<Complaint> srcResult = [];
    try {
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            "act": "srchcmplntlst",
            "clntId": clntId,
            "uid": uid,
            "name": name,
            "crit": crit,
            "srcCmpno": srcCmpno,
            "inclUndr": inclUndr
          },
        ),
      );
      final result = json.decode(resp.body);
      sResult = result;
      print("Complaint search from server: $result");
      if (result['Result'] == "OK") {
        final records = result["Records"] as List<dynamic>;
        srcResult = records
            .map((cmplnt) => Complaint(
                  act: cmplnt['act'],
                  cmpId: cmplnt['cmpId'],
                  cmpcatid: cmplnt['cmpcatid'],
                  cmpCat: cmplnt['cmpCat'],
                  cmpLvl: cmplnt['cmpLvl'],
                  cmpLvlNm: cmplnt['cmpLvlNm'],
                  desc: cmplnt['desc'],
                  cmpFldr: cmplnt['cmpFldr'],
                  cmpisAttch: cmplnt['cmpisAttch'],
                  cmpAssigndTo: cmplnt['cmpAssigndTo'],
                  cmpAssignd: cmplnt['cmpAssignd'],
                  cmpInitBy: cmplnt['cmpInitBy'],
                  cmpRcntRply: cmplnt['cmpRcntRply'],
                  cmpRjcnt: cmplnt['cmpRjcnt'],
                  id: cmplnt['id'],
                  uid: cmplnt['uid'],
                  clntId: cmplnt['clntId'],
                  name: cmplnt['name'],
                  crit: cmplnt['crit'],
                  rmrk: cmplnt['rmrk'],
                  typ: cmplnt['typ'],
                  stat: cmplnt['stat'],
                  regon: cmplnt['regon'],
                  regby: cmplnt['regby'],
                  updton: cmplnt['updton'],
                  updtby: cmplnt['updtby'],
                  upldfls: cmplnt['upldfls'],
                ))
            .toList();
      }
    } catch (error) {
      print("Error ==> $error");
      throw error;
    }
    _complaints = srcResult;
    notifyListeners();
    return sResult;
  }

  Future getComplaintSummary() async {
    var url = Uri.parse("$api/userapp/cmplntsmryrvc");
    Map<String, dynamic> sResult = {};
    List<ComplaintSummary> loadedSummary = [];
    try {
      final resp = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(
            {
              "act": "getusrsmry",
              "clntId": clntId,
              "uid": uid,
              "name": name,
            },
          ));
      final result = json.decode(resp.body);
      sResult = result;
      print("Complaint summary from server: $result");
      if (result['Result'] == "OK") {
        final summary = result['Records'] as List<dynamic>;
        loadedSummary = summary
            .map((summ) => ComplaintSummary(
                value: summ['value'],
                text: summ['text'],
                no: summ['no'],
                extra: summ['extra'],
                extrainfo: summ['extrainfo']))
            .toList();

        _complaintSummary = loadedSummary;
      }
    } catch (error) {
      _complaintSummary = loadedSummary;
      print("Error => $error");
      throw error;
    }
    return sResult;
  }

  Future<List<Comment>> getComments(int cmpId) async {
    List<Comment> loadedComments = [];

    var url = Uri.parse("$api/userapp/cmplntmangesrvc");
    try {
      final resp = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(
            {
              "act": "getcomments",
              "clntId": clntId,
              "uid": uid,
              "name": name,
              "id": cmpId,
              "typ": "cmplnt",
            },
          ));
      final result = json.decode(resp.body);

      print("comments response from server: $result");
      final comm = result['Records'] as List<dynamic>;
      loadedComments = comm
          .map((comment) => Comment(
              value: comment['value'],
              text: comment['text'],
              no: comment['no'],
              extra: comment['extra'],
              extrainfo: comment['extrainfo']))
          .toList();
    } catch (error) {
      print("Error => $error");
      throw error;
    }
    return loadedComments;
  }

  Future updateComplaint(int cmpId, String stat, String rmrk) async {
    var url = Uri.parse("$api/userapp/cmplntmangesrvc");
    try {
      final resp = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(
            {
              "act": "updtcmplntstat",
              "clntId": clntId,
              "uid": uid,
              "name": name,
              "id": cmpId,
              "stat": stat,
              "rmrk": rmrk
            },
          ));
      final result = json.decode(resp.body);
      print("Update complaint response from server: $result");
      if (result['Result'] == "OK") {
        _complaint.stat = stat;
        removeItem(cmpId);
      }
      return result;
    } catch (error) {
      print("Error => $error");
      throw error;
    }
  }

  Future fetchAndSetcomplaints(String crit) async {
    var url = Uri.parse("$api/userapp/cmplntmangesrvc");
    var complaintData;
    List<Complaint> loadedComplaints = [];
    try {
      final resp = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(
            {
              "act": "getregcmplntlst",
              "crit": crit,
              "clntId": clntId,
              "uid": uid,
              "name": name,
            },
          ));
      complaintData = json.decode(resp.body);

      print("fetched complaint data ==> $complaintData");
      if (complaintData['Result'] == "OK") {
        final records = complaintData['Records'] as List<dynamic>;
        loadedComplaints = records
            .map((cmplnt) => Complaint(
                  act: cmplnt['act'],
                  cmpId: cmplnt['cmpId'],
                  cmpcatid: cmplnt['cmpcatid'],
                  cmpCat: cmplnt['cmpCat'],
                  cmpLvl: cmplnt['cmpLvl'],
                  cmpLvlNm: cmplnt['cmpLvlNm'],
                  desc: cmplnt['desc'],
                  cmpFldr: cmplnt['cmpFldr'],
                  cmpisAttch: cmplnt['cmpisAttch'],
                  cmpAssigndTo: cmplnt['cmpAssigndTo'],
                  cmpAssignd: cmplnt['cmpAssignd'],
                  cmpInitBy: cmplnt['cmpInitBy'],
                  cmpRcntRply: cmplnt['cmpRcntRply'],
                  cmpRjcnt: cmplnt['cmpRjcnt'],
                  id: cmplnt['id'],
                  uid: cmplnt['uid'],
                  clntId: cmplnt['clntId'],
                  name: cmplnt['name'],
                  crit: cmplnt['crit'],
                  rmrk: cmplnt['rmrk'],
                  typ: cmplnt['typ'],
                  stat: cmplnt['stat'],
                  regon: cmplnt['regon'],
                  regby: cmplnt['regby'],
                  updton: cmplnt['updton'],
                  updtby: cmplnt['updtby'],
                  upldfls: cmplnt['upldfls'],
                ))
            .toList();
      }
    } catch (error) {
      print("Error ==> $error");
      throw error;
    }
    _complaints = loadedComplaints;
    notifyListeners();
    return complaintData;
  }

  Future saveComplaint(Complaint complaint, PlatformFile uploadfile) async {
    print("uid $uid");
    print("clntId $clntId");
    print("name $name");
    print("complaint.cmpcatid ${complaint.cmpcatid}");
    print("complaint.desc ${complaint.desc}");

    var url = Uri.parse("$api/userapp/cmplntmangesrvc");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "act": "savecmplnt",
          "cmpcatid": complaint.cmpcatid,
          "desc": complaint.desc,
          "cmpisAttch": uploadfile != null ? "Y" : "N", //complaint.cmpisAttch,
          "clntId": clntId,
          "uid": uid,
          "name": name
        }),
      );
      final compSaveResp = json.decode(response.body);
      print("Response from server complaint save ==> $compSaveResp");
      if (compSaveResp['Result'] == "OK") {
        if (compSaveResp['rtyp'] == "N") {
          fetchAndSetcomplaints("Y");
          return compSaveResp;
        }
        var url2 = Uri.parse("$api/userapp/fleUpldsrvc");
        var request = http.MultipartRequest('POST', url2);
        request.files.add(await http.MultipartFile.fromPath(
          'fleupldsp',
          uploadfile.path,
        ));
        request.fields['act'] = 'cmplntfl';
        request.fields['id'] = compSaveResp['rscnt'].toString();
        request.fields['clntId'] = clntId.toString();
        request.fields['uid'] = uid.toString();
        request.fields['name'] = name;
        var fileUploadresp = await request.send();

        print("Server Response on file upload ==> $fileUploadresp");
        print(
            "Server statusCode on file upload ==> ${fileUploadresp.statusCode}");
        print("Server stream on file upload ==> ${fileUploadresp.stream}");
        print("Server String on file upload ==> ${fileUploadresp.toString()}");

        if (fileUploadresp.statusCode == 200) {
          compSaveResp['Msg'] += " File is uploaded.";
        } else {
          compSaveResp['Msg'] += " Unable to upload the file.";
        }
      }

      print("Response from server complaint save ==> $compSaveResp");
      fetchAndSetcomplaints("Y");
      return compSaveResp;
    } catch (error) {
      print("Error ==> $error");
      throw error;
    }
  }
}

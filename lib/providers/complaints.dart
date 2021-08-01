import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as httpReq;
import 'package:http_interceptor/http_interceptor.dart';

import '../Interceptor/interceptor.dart';
import '../models/remark.dart';
import '../models/complaint_summary.dart';
import '../models/comments.dart';
import '../models/complaint.dart';
import '../helpers/db_helper.dart';
import '../config/env.dart';

class Complaints with ChangeNotifier {
  final String api = Environment.url;
  List<Complaint> _complaints = [];
  Complaint _complaint = Complaint();
  List<ComplaintSummary> _underMyAuthority = [];
  List<ComplaintSummary> _assignedToMe = [];
  List<ComplaintSummary> _myComplaints = [];
  int _reportingCount = 0;
  List<Remark> _remarks = [];
  List<Comment> _comments = [];
  final http = InterceptedHttp.build(interceptors: [
    HttpInterceptor(),
  ]);

  int uid;
  int clntId;
  String name;

// Constructor to get the logged in user data from Auth provider class
  Complaints(this.uid, this.clntId, this.name, this._complaints);

  List<Complaint> get complaints {
    // returns the copy of _complaints
    return [..._complaints];
  }

  List<Comment> get comments {
    return [..._comments];
  }

  Complaint get complaint {
    // returns the single complaint
    return _complaint;
  }

  List<ComplaintSummary> get underMyAuthority {
    // returns the underMyAuthority complaint summary to display on dashboard
    return [..._underMyAuthority];
  }

  List<ComplaintSummary> get assignedToMe {
    // returns the assignedToMe complaint summary to display on dashboard
    return [..._assignedToMe];
  }

  List<ComplaintSummary> get myComplaints {
    // returns the myComplaints complaint summary to display on dashboard
    return [..._myComplaints];
  }

  int get reportingUsers {
    return _reportingCount;
  }

// Method to find the complaint by it's id
  Future<void> findById(int cmpId) async {
    _complaint = _complaints.firstWhere((comp) => comp.cmpId == cmpId);
  }

// remove single complaint from the _complaints list
  void removeItem(int cmpId) {
    _complaints.removeWhere((cmp) => cmp.cmpId == cmpId);
    notifyListeners();
  }

// Download the attachment file in the complaint
  Future downloadAttachment(int cmplId) async {
    var url = Uri.parse("$api/userapp/fleDownldsrvc");

    try {
      final resp = await http.post(
        url,
        // headers: {"Content-Type": "application/json"},
        body: utf8.encode(
          json.encode(
            {
              "act": "cmplnt",
              "doctyp": "cmplnt",
              "id": cmplId,
              "clntId": clntId,
              "uid": uid,
              "name": name,
            },
          ),
        ),
      );
      if (resp.contentLength == 0) {
        return;
      }
      final data = resp.headers['content-disposition'];
      final fname = data.substring(data.indexOf('=') + 1, data.indexOf('"'));
      return {"fileBytes": resp.bodyBytes, "fileName": fname.toString()};
    } catch (error) {
      // throw error;
    }
  }

  // Search complaint from the server based on different complainations of filters and criterias
  Future serachComplaint(String crit, String srcCmpno, String inclUndr) async {
    var sResult;
    var url = Uri.parse("$api/userapp/cmplntmangesrvc");

    List<Complaint> srcResult = [];
    try {
      final resp = await http.post(
        url,
        // headers: {"Content-Type": "application/json"},
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
      throw error;
    }
    _complaints = srcResult;
    notifyListeners();
    return sResult;
  }

  // Fetch the complaints summary to display on dashboard
  Future getComplaintSummary() async {
    var url = Uri.parse("$api/userapp/cmplntsmryrvc");
    Map<String, dynamic> sResult = {};
    List<ComplaintSummary> loadedUnderYouSummary = [];
    List<ComplaintSummary> loadedAsignToMeSummary = [];
    List<ComplaintSummary> loadedMyCmplSummary = [];
    int userUnder = 0;
    try {
      final resp = await http.post(url,
          // headers: {"Content-Type": "application/json"},
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
      if (result['Result'] == "OK") {
        userUnder = result['Record'] as int;
        _reportingCount = userUnder;
        final underYou = result['Records'] as List<dynamic>;
        loadedUnderYouSummary = underYou
            .map((summ) => ComplaintSummary(
                value: summ['value'],
                text: summ['text'],
                no: summ['no'],
                extra: summ['extra'],
                extrainfo: summ['extrainfo']))
            .toList();
        _underMyAuthority = loadedUnderYouSummary;
        final assignedYou = result['data'] as List<dynamic>;
        loadedAsignToMeSummary = assignedYou
            .map((summ) => ComplaintSummary(
                value: summ['value'],
                text: summ['text'],
                no: summ['no'],
                extra: summ['extra'],
                extrainfo: summ['extrainfo']))
            .toList();
        _assignedToMe = loadedAsignToMeSummary;
        final myCmpl = result['data1'] as List<dynamic>;
        loadedMyCmplSummary = myCmpl
            .map((summ) => ComplaintSummary(
                value: summ['value'],
                text: summ['text'],
                no: summ['no'],
                extra: summ['extra'],
                extrainfo: summ['extrainfo']))
            .toList();
        _myComplaints = loadedMyCmplSummary;
        notifyListeners();
      }
    } catch (error) {
      _reportingCount = userUnder;
      _underMyAuthority = loadedUnderYouSummary;
      _assignedToMe = loadedAsignToMeSummary;
      _myComplaints = loadedMyCmplSummary;
      notifyListeners();
      throw error;
    }
    return sResult;
  }

// This method returns the remarks on perticular complaint
  Future getComments(int cmpId) async {
    List<Comment> loadedComments = [];
    var result;

    var url = Uri.parse("$api/userapp/cmplntmangesrvc");
    try {
      final resp = await http.post(url,
          // headers: {"Content-Type": "application/json"},
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
      result = json.decode(resp.body);
      if (result['Result'] == "OK") {
        final comm = result['Records'] as List<dynamic>;
        loadedComments = comm
            .map((comment) => Comment(
                value: comment['value'],
                text: comment['text'],
                no: comment['no'],
                extra: comment['extra'],
                extrainfo: comment['extrainfo']))
            .toList();
      }
      _comments = loadedComments;
      notifyListeners();
    } catch (error) {
      throw error;
    }
    return result;
  }

// Update the status with remark on complaint
  Future updateComplaint(
      int cmpId, String stat, String rmrk, bool rmrkSvFlag) async {
    var url = Uri.parse("$api/userapp/cmplntmangesrvc");
    try {
      final resp = await http.post(url,
          // headers: {"Content-Type": "application/json"},
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
      if (result['Result'] == "OK") {
        if (rmrkSvFlag) {
          saveRemark(rmrk);
        }
        _complaint.stat = stat;
        if (stat != "H") {
          removeItem(cmpId);
        }
      }
      return result;
    } catch (error) {
      throw error;
    }
  }

  // This method fetch all the complaints from the server based on criteria which we provide
  Future fetchAndSetcomplaints(String crit) async {
    var url = Uri.parse("$api/userapp/cmplntmangesrvc");
    var complaintData;
    List<Complaint> loadedComplaints = [];
    try {
      final resp = await http.post(url,
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
      throw error;
    }
    _complaints = loadedComplaints;
    notifyListeners();
    return complaintData;
  }

  Future saveComplaint(Complaint complaint, String uploadfilePath) async {
    var url = Uri.parse("$api/userapp/cmplntmangesrvc");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "act": "savecmplnt",
          "cmpcatid": complaint.cmpcatid,
          "desc": complaint.desc,
          "cmpisAttch":
              uploadfilePath != null ? "Y" : "N", //complaint.cmpisAttch,
          "clntId": clntId,
          "uid": uid,
          "name": name
        }),
      );
      final compSaveResp = json.decode(response.body);
      if (compSaveResp['Result'] == "OK") {
        if (compSaveResp['rtyp'] == "N") {
          fetchAndSetcomplaints("IP");
          return compSaveResp;
        }
        var url2 = Uri.parse("$api/userapp/fleUpldsrvc");
        var request = httpReq.MultipartRequest('POST', url2);
        request.files.add(await httpReq.MultipartFile.fromPath(
          'fleupldsp',
          uploadfilePath,
        ));
        request.fields['act'] = 'cmplntfl';
        request.fields['id'] = compSaveResp['rscnt'].toString();
        request.fields['clntId'] = clntId.toString();
        request.fields['uid'] = uid.toString();
        request.fields['name'] = name;
        var fileUploadresp = await request.send();

        if (fileUploadresp.statusCode == 200) {
          compSaveResp['Msg'] += " File is uploaded.";
        } else {
          compSaveResp['Msg'] += " Unable to upload the file.";
        }
      }

      fetchAndSetcomplaints("IP");
      return compSaveResp;
    } catch (error) {
      throw error;
    }
  }

  List<Remark> get savedRemarks {
    return [..._remarks];
  }

  Future<void> saveRemark(String rmrk) async {
    if (rmrk.trim() != '') {
      DBHelper.insert('remarks', {'remark': rmrk});
    }
  }

  Future<void> fetchSavedComments() async {
    final remarks = await DBHelper.getLocalRemarks('remarks');
    _remarks = remarks
        .map((remark) => Remark(
              id: remark['id'],
              title: remark['remark'].length > 15
                  ? "${remark['remark'].substring(0, 15)}..."
                  : remark['remark'],
              remark: remark['remark'],
            ))
        .toList();
    notifyListeners();
  }

  Future<void> deleteRemarkById(int id) async {
    if (id != null) {
      await DBHelper.delete('remarks', id);
      fetchSavedComments();
    }
  }
}

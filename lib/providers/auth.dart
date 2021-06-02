import 'dart:convert';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';
import '../models/login.dart';
import '../models/signup.dart';
import '../config/env.dart';

class Auth with ChangeNotifier {
  FirebaseMessaging _fcmMessaging = FirebaseMessaging.instance;
  Map<String, dynamic> _userData;
  final String api = Environment.url;
  int _uid;
  int _clntId;
  String _uFname;
  String _uLname;
  String _fcmToken;
  Profile _userProfile = Profile(
      uid: null,
      mainclntofc: "",
      clntid: null,
      uFname: "",
      uMname: "",
      uLname: "",
      uDesgId: null,
      uDesgNm: "",
      uSevarthNo: "",
      uMobile: "",
      uEmail: "",
      uOfcId: null,
      uOfcNm: "",
      uReportUid: null,
      uReportUNm: "",
      uLoginId: "",
      uPwd: "",
      uTyp: "",
      stat: "",
      regon: "",
      regby: "",
      updon: "",
      updby: "");

  int get uid {
    if (_uid != null) {
      return _uid;
    }
    return null;
  }

  int get clntId {
    if (_clntId != null) {
      return _clntId;
    }
    return null;
  }

  String get name {
    if (_uFname != null && _uLname != null) {
      return "$_uFname $_uLname";
    }
    return null;
  }

  Map<String, Object> get loggedInUserData {
    return _userData = {
      'clntId': _clntId,
      'uid': _uid,
      'uFname': _uFname,
      'uLname': _uLname,
      'name': '$_uFname $_uLname',
    };
  }

  bool get isAuth {
    return _uid != null;
  }

  Map<String, dynamic> get userData {
    if (_userData != null) {
      return _userData;
    }
    return null;
  }

  Profile get userProfile {
    return _userProfile;
  }

  Future updateOrRegisterFCMToken(int clntId, int uid, String name) async {
    var url = Uri.parse("$api/userapp/updtfcm");
    final token = await _fcmMessaging.getToken(); // get FCM token here
    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "clntId": clntId,
            "uid": uid,
            "name": name,
            "tkn": token,
          }));
      final result = json.decode(response.body);
      if (result['Result'] == "NOK") {
        return;
      }
      return token;
    } catch (error) {
      throw error;
    }
  }

  Future appUpdateDownload(String targetURL) async {
    try {
      final response = await http.get(
        Uri.parse(targetURL),
        headers: {"Content-Type": "application/json"},
      );
      if (response.contentLength == 0) {
        return;
      }
      return response.bodyBytes;
    } catch (error) {
      throw error;
    }
  }

  Future checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    var url = Uri.parse("$api/userapp/appversion");
    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({"version": version}));
      final result = json.decode(response.body);
      if (result['Result'] == "NOK") {
        return result;
      }
    } catch (error) {
      throw error;
    }
  }

  Future changePassword(String loginId, String pwd) async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "act": "updtpwd",
          "clntId": _clntId,
          "uid": _uid,
          "name": "$_uFname $_uLname",
          "uLogin": loginId,
          "uPwd": pwd,
        }),
      );
      return json.decode(response.body);
    } catch (error) {
      throw error;
    }
  }

  Future updateProfile(String uFname, String uMname, String uLname,
      String uMobile, String uEmail) async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    var rObject;
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "act": "updtprofile",
          "clntId": _clntId,
          "uid": _uid,
          "name": "$_uFname $_uLname",
          "uFname": uFname,
          "uMname": uMname,
          "uLname": uLname,
          "uMobile": uMobile,
          "uEmail": uEmail
        }),
      );
      rObject = json.decode(response.body) as Map;
      if (rObject["Result"] == "OK") {
        getProfile();
      }
    } catch (error) {
      throw error;
    }
    return rObject;
  }

  Future getProfile() async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    Profile loadProfile;
    var object = {};

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "act": "getprofile",
          "clntId": _clntId,
          "uid": _uid,
          name: "$_uFname $_uLname"
        }),
      );
      object = json.decode(response.body);
      if (object["Result"] == "OK") {
        final tempProf = object["Record"] as Map<String, dynamic>;
        loadProfile = Profile(
          uid: tempProf['uid'],
          mainclntofc: tempProf['mainclntofc'],
          clntid: tempProf['clntid'],
          uFname: tempProf['uFname'],
          uMname: tempProf['uMname'],
          uLname: tempProf['uLname'],
          uDesgId: tempProf['uDesgId'],
          uDesgNm: tempProf['uDesgNm'],
          uSevarthNo: tempProf['uSevarthNo'],
          uMobile: tempProf['uMobile'],
          uEmail: tempProf['uEmail'],
          uOfcId: tempProf['uOfcId'],
          uOfcNm: tempProf['uOfcNm'],
          uReportUid: tempProf['uReportUid'],
          uReportUNm: tempProf['uReportUNm'],
          uLoginId: tempProf['uLoginId'],
          uPwd: tempProf['uPwd'],
          uTyp: tempProf['uTyp'],
          stat: tempProf['stat'],
          regon: tempProf['regon'],
          regby: tempProf['regby'],
          updon: tempProf['updon'],
          updby: tempProf['updby'],
        );
      }
    } catch (error) {
      throw error;
    }
    _userProfile = loadProfile;
    notifyListeners();
    return object;
  }

  Future signUp(Signup userData) async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "mainofcNm": userData.mainofcNm,
          "mainclntofc": userData.mainclntofc,
          "clntId": userData.clntId,
          "uFname": userData.uFname,
          "uMname": userData.uMname,
          "uLname": userData.uLname,
          "uDesgId": userData.uDesgId,
          "uDesgNm": userData.uDesgNm,
          "uSevarthNo": userData.uSevarthNo,
          "uMobile": userData.uMobile,
          "uEmail": userData.uEmail,
          "uOfcId": userData.uOfcId,
          "uOfcNm": userData.uOfcNm,
          "uReportUid": userData.uReportUid,
          "uReportUNm": userData.uReportUNm,
          "uLoginId": userData.uLoginId,
          "uPwd": userData.uPwd,
          "act": userData.act,
        }),
      );
      final signUpResp = json.decode(response.body);
      return signUpResp;
    } catch (error) {
      throw error;
    }
  }

  Future verifyLoginId(String loginId) async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"act": "verfyloginid", "uLogin": loginId}),
      );
      return json.decode(response.body);
    } catch (error) {
      throw error;
    }
  }

  Future login(Login loginData) async {
    var url = Uri.parse("$api/userapp/applogin");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            'clntId': "4G0T337M",
            'uLogin': loginData.uLogin,
            'uPwd': loginData.uPwd
          },
        ), // 4G0T337M   prod => YKV9BWUK
      );
      final loginResp = json.decode(response.body) as Map<String, dynamic>;

      if (loginResp['Result'] == "OK") {
        final record = loginResp['Record'] as Map<String, dynamic>;
        final respToken = await updateOrRegisterFCMToken(record['clntid'],
            record['uid'], "${record['uFname']} ${record['uLname']}");
        if (respToken != null) {
          _clntId = record['clntid'];
          _uid = record['uid'];
          _uFname = record['uFname'];
          _uLname = record['uLname'];
          _fcmToken = respToken.toString();
          notifyListeners();
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt("clntId", _clntId);
          prefs.setInt("uid", _uid);
          prefs.setString("uFname", _uFname);
          prefs.setString("uLname", _uLname);
          prefs.setString("fcmToken", _fcmToken);
          return 0;
        }
        return "Invalid Token";
      } else {
        return loginResp['Msg'];
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('uid')) {
      return false;
    }
    _uid = prefs.getInt('uid');
    _clntId = prefs.getInt('clntId');
    _uFname = prefs.getString('uFname');
    _uLname = prefs.getString('uLname');
    _fcmToken = prefs.getString('fcmToken');
    notifyListeners();
    return true;
  }

  void logout() async {
    _clntId = null;
    _uid = null;
    _uFname = null;
    _uLname = null;
    // _fcmToken = null;
    // _fcmMessaging.deleteToken();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    prefs.remove('clntId');
    prefs.remove('uFname');
    prefs.remove('uLname');

    // prefs.clear();
  }
}

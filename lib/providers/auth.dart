import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';
import '../models/login.dart';
import '../models/signup.dart';
import '../config/env.dart';

class Auth with ChangeNotifier {
  Map<String, dynamic> _userData;
  final String api = Environment.url;
  int _uid;
  int _clntId;
  String _uFname;
  String _uLname;
  Profile _userProfile = Profile(
      uid: null,
      mainclntofc: "",
      clntid: null,
      uFname: "",
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

  Future checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    print("version is: $version");
    var url = Uri.parse("$api/userapp/appversion");
    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({"version": version}));
      final result = json.decode(response.body);
      if (result['Result'] == "NOK") {
        print("Version check response from server:  ${response.body}");
        return result;
      }
    } catch (error) {
      print("Error while cheking version ==> $error");
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
      print("Error ==> $error");
      throw error;
    }
  }

  Future updateProfile(
      String uFname, String uLname, String uMobile, String uEmail) async {
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
      print("Error ==> $error");
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
      print("Profile response from serve $object");
      if (object["Result"] == "OK") {
        final tempProf = object["Record"] as Map<String, dynamic>;
        loadProfile = Profile(
          uid: tempProf['uid'],
          mainclntofc: tempProf['mainclntofc'],
          clntid: tempProf['clntid'],
          uFname: tempProf['uFname'],
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
      print("Error ==> $error");
      throw error;
    }
    _userProfile = loadProfile;
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
      print("Error => $error");
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
      print("verifyLoginId response from serve: ${response.body}");
      return json.decode(response.body);
    } catch (error) {
      print("Error while checking login Id => $error");
      throw error;
    }
  }

  Future login(Login loginData) async {
    var url = Uri.parse("$api/userapp/applogin");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'uLogin': loginData.uLogin, 'uPwd': loginData.uPwd}),
      );
      final loginResp = json.decode(response.body) as Map<String, dynamic>;
      print("Rsponse Login Attempt ===> $loginResp");
      if (loginResp['Result'] == "OK") {
        final record = loginResp['Record'] as Map<String, dynamic>;
        _clntId = record['clntid'];
        _uid = record['uid'];
        _uFname = record['uFname'];
        _uLname = record['uLname'];
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt("clntId", _clntId);
        prefs.setInt("uid", _uid);
        prefs.setString("uFname", _uFname);
        prefs.setString("uLname", _uLname);
        return 0;
      } else {
        return loginResp['Msg'];
      }
    } catch (error) {
      print("Error while login => $error");
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
    notifyListeners();
    return true;
  }

  void logout() async {
    _clntId = null;
    _uid = null;
    _uFname = null;
    _uLname = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }
}

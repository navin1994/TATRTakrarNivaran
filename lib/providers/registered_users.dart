import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import '../models/registered_user.dart';
import '../config/env.dart';

class RegisteredUsers with ChangeNotifier {
  final api = Environment.url;
  List<RegisteredUser> _registeredUsers = [];
  RegisteredUser _regUser = RegisteredUser();

  int uid;
  int clntId;
  String name;

  RegisteredUsers(this.uid, this.clntId, this.name, this._registeredUsers);

  List<RegisteredUser> get registeredUsers {
    return [..._registeredUsers];
  }

  RegisteredUser get regUser {
    return _regUser;
  }

  Future<void> findById(int uid) async {
    _regUser = _registeredUsers.firstWhere((user) => user.uid == uid);
  }

  void removeItem(int userId) {
    _registeredUsers.removeWhere((user) => user.uid == userId);
    notifyListeners();
  }

  Future fetchAndSetRegisteredUsers(String crit) async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "act": "getreguserlst",
          "crit": crit,
          "clntId": clntId,
          "uid": uid,
          "name": name
        }),
      );
      List<RegisteredUser> loadedRegisteredUsers = [];
      final result = json.decode(response.body);
      if (result['Result'] == "OK") {
        final rUsers = result['Records'] as List<dynamic>;
        loadedRegisteredUsers = rUsers
            .map(
              (user) => RegisteredUser(
                  uid: user['uid'],
                  mainclntofc: user['mainclntofc'],
                  clntid: user['clntid'],
                  uFname: user['uFname'],
                  uMname: user['uMname'],
                  uLname: user['uLname'],
                  uDesgId: user['uDesgId'],
                  uDesgNm: user['uDesgNm'],
                  uSevarthNo: user['uSevarthNo'],
                  uMobile: user['uMobile'],
                  uEmail: user['uEmail'],
                  uOfcId: user['uOfcId'],
                  uOfcNm: user['uOfcNm'],
                  uReportUid: user['uReportUid'],
                  uReportUNm: user['uReportUNm'],
                  uLoginId: user['uLoginId'],
                  uTyp: user['uTyp'],
                  stat: user['stat'],
                  regon: user['regon'],
                  regby: user['regby'],
                  updon: user['updon'],
                  updby: user['updby']),
            )
            .toList();
      } else {
        _registeredUsers = loadedRegisteredUsers;
        notifyListeners();
        return result['Msg'];
      }
      _registeredUsers = loadedRegisteredUsers;
      notifyListeners();
      return 0;
    } catch (error) {
      _registeredUsers = [];
      notifyListeners();
      throw error;
    }
  }

  Future updateUserStatus(String stat, int userid) async {
    var url = Uri.parse("$api/userapp/datcmplntsrvc");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "act": "actregusrstat",
          "stat": stat,
          "clntId": clntId,
          "uid": uid,
          "name": name,
          "id": userid,
        }),
      );
      final result = json.decode(response.body);
      if (result['Result'] == "OK") {
        _regUser.stat = stat;
        removeItem(userid);
      }
      return result;
    } catch (error) {
      throw error;
    }
  }
}

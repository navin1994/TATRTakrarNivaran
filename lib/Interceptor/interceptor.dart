import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({@required RequestData data}) async {
    try {
      data.headers["Content-Type"] = "application/json";
      var token = await getToken();
      if (token != null) {
        Map temp = json.decode(data.body);
        temp['token'] = token;
        data.body = json.encode(temp);
      }
    } catch (error) {
      throw error;
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({@required ResponseData data}) async {
    print("Response From Server : ==> ${data.body}");
    return data;
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('loginToken')) {
      return null;
    }
    return prefs.getString('loginToken');
  }
}

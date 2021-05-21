import 'package:flutter/foundation.dart';

class Signup {
  final String mainofcNm;
  final String mainclntofc;
  final int clntId;
  final String uFname;
  final String uMname;
  final String uLname;
  final int uDesgId;
  final String uDesgNm;
  final String uSevarthNo;
  final String uMobile;
  final String uEmail;
  final int uOfcId;
  final String uOfcNm;
  final int uReportUid;
  final String uReportUNm;
  final String uLoginId;
  final String uPwd;
  final String act;

  Signup({
    @required this.mainofcNm,
    @required this.mainclntofc,
    @required this.clntId,
    @required this.uFname,
    @required this.uMname,
    @required this.uLname,
    @required this.uDesgId,
    @required this.uDesgNm,
    @required this.uSevarthNo,
    @required this.uMobile,
    this.uEmail,
    @required this.uOfcId,
    @required this.uOfcNm,
    @required this.uReportUid,
    @required this.uReportUNm,
    @required this.uLoginId,
    @required this.uPwd,
    this.act = "saveuserreg",
  });
}

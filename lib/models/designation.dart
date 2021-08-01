import 'package:flutter/foundation.dart';

class Designation {
  final int hdid;
  final String hdnm;
  final String hddtls;
  final int undhd;
  final String undhdNm;
  final int hdlvl;
  final String stat;
  final String regon;
  final String regby;
  Designation({
    @required this.hdid,
    @required this.hdnm,
    @required this.hddtls,
    @required this.undhd,
    @required this.undhdNm,
    @required this.hdlvl,
    @required this.stat,
    @required this.regon,
    @required this.regby,
  });
}

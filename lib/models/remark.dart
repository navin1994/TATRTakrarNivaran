import 'package:flutter/foundation.dart';

class Remark {
  final int id;
  final String title;
  final String remark;
  bool isExpanded;
  Remark({
    @required this.id,
    @required this.title,
    @required this.remark,
    this.isExpanded = false,
  });
}

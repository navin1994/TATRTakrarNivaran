import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/complaint_summary.dart';
import '../widgets/complaint_type_count.dart';
import '../translations/locale_keys.g.dart';

class ComplaintsCount extends StatelessWidget {
  final String title;
  final String routingFlag;
  final List<ComplaintSummary> data;
  const ComplaintsCount(this.title, this.routingFlag, this.data);
  String get _inclUnder {
    switch (routingFlag) {
      case "AsnToMe":
        return "A";
      case "UndrMe":
        return "U";
      case "Rsd":
        return "R";
      default:
        return "R";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.white),
      // ),
      height: 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(
                  "$title",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              padding: const EdgeInsets.all(5),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                ComplaintTypeCount(
                  LocaleKeys.total.tr(),
                  data[0].value,
                  [Colors.green, Colors.yellow],
                  7,
                  _inclUnder,
                ),
                ComplaintTypeCount(
                  LocaleKeys.closed.tr(),
                  data[2].value,
                  [Colors.blue, Colors.lightBlue],
                  4,
                  _inclUnder,
                ),
                ComplaintTypeCount(
                  LocaleKeys.solved.tr(),
                  data[1].value,
                  [Colors.orangeAccent[700], Colors.pinkAccent[400]],
                  3,
                  _inclUnder,
                ),
                ComplaintTypeCount(
                  LocaleKeys.pending.tr(),
                  data[3].value,
                  [Colors.pink[300], Colors.pink[100]],
                  2,
                  _inclUnder,
                ),
                ComplaintTypeCount(
                  LocaleKeys.on_hold.tr(),
                  data[5].value,
                  [Colors.cyanAccent[200], Colors.blueGrey[400]],
                  5,
                  _inclUnder,
                ),
                ComplaintTypeCount(
                  LocaleKeys.not_acted_in_7_days.tr(),
                  data[4].value,
                  [Colors.lightGreen[400], Colors.pink[200]],
                  6,
                  _inclUnder,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../translations/locale_keys.g.dart';

class Tilewidget extends StatelessWidget {
  final Color color;
  final Icon icon;
  final String symbol;
  final double perc;
  final Color textcolor;
  final int count;
  const Tilewidget(
      {Key key,
      @required this.color,
      @required this.symbol,
      @required this.icon,
      @required this.perc,
      @required this.textcolor,
      @required this.count})
      : super(key: key);

  Widget get _getLabel {
    switch (symbol) {
      case "TOTAL":
        return Text("${LocaleKeys.total.tr()}",
            style: TextStyle(color: Colors.white));
      case "Solved":
        return Text("${LocaleKeys.solved.tr()}",
            style: TextStyle(color: Colors.white));
      case "Closed":
        return Text("${LocaleKeys.closed.tr()}",
            style: TextStyle(color: Colors.white));
      case "Pending":
        return Text("${LocaleKeys.pending.tr()}",
            style: TextStyle(color: Colors.white));
      case "Not acted in 7 Days":
        return Text("${LocaleKeys.not_acted_in_7_days.tr()}",
            style: TextStyle(color: Colors.white));
      case "On-Hold":
        return Text("${LocaleKeys.on_hold.tr()}",
            style: TextStyle(color: Colors.white));
      default:
        return Text("${LocaleKeys.rejec.tr()}",
            style: TextStyle(color: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      margin: EdgeInsets.symmetric(vertical: 6),
      height: 75,
      decoration: BoxDecoration(
          color: Color.fromRGBO(34, 37, 42, 1),
          border: Border.all(
            color: Colors.white30,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(18)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.53,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: this.color,
                  child: this.icon,
                ),
                FittedBox(
                  child: _getLabel,
                ),
                // Text('$symbol', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.21,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 1,
                  color: Colors.grey,
                ),
                Text('$count', style: TextStyle(color: Colors.white)),
                Container(
                  width: 1,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.12,
            child: Text(
              '${perc.toStringAsFixed(0) == 'NaN' ? 0 : perc.toStringAsFixed(0)} %',
              style: TextStyle(color: this.textcolor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

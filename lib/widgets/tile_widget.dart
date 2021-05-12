import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      margin: EdgeInsets.symmetric(vertical: 6),
      height: 75,
      decoration: BoxDecoration(
          color: Color.fromRGBO(34, 37, 42, 1),
          borderRadius: BorderRadius.circular(18)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 120,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: this.color,
                  child: this.icon,
                ),
                Text('$symbol', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey,
          ),
          Text('$count', style: TextStyle(color: Colors.white)),
          Container(
            width: 1,
            color: Colors.grey,
          ),
          Container(
            child: Text(
              '${perc.toStringAsFixed(0) == 'NaN' ? 0 : perc.toStringAsFixed(0)} %',
              style: TextStyle(color: this.textcolor),
            ),
          ),
        ],
      ),
    );
  }
}

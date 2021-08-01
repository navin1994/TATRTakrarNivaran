import 'package:flutter/material.dart';

import '../models/filter_cmpl_args.dart';
import '../screens/complaint_management_screen.dart';

class ComplaintTypeCount extends StatelessWidget {
  final String title;
  final List<Color> color;
  final String count;
  final int indexFilter;
  final String inclUnder;

  const ComplaintTypeCount(
    this.title,
    this.count,
    this.color,
    this.indexFilter,
    this.inclUnder,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
          ComplaintManagementScreen.routeName,
          arguments:
              FilterComplaintArgs(indx: indexFilter, srcUnder: inclUnder)),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: color,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.none,
                child: Text(
                  count,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

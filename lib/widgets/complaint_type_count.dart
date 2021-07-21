import 'package:flutter/material.dart';

import '../models/filter_cmpl_args.dart';
import '../screens/complaint_management_screen.dart';

class ComplaintTypeCount extends StatelessWidget {
  final String title;
  final Color color;
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
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                count,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

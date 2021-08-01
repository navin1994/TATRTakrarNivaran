import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';

class ComplaintCard extends StatelessWidget {
  final int itemIndex;
  final String name;
  final int complaintCode;
  final String date;
  final String category;
  final String status;
  final Function press;
  ComplaintCard({
    this.itemIndex,
    this.name,
    this.complaintCode,
    this.date,
    this.category,
    this.status,
    this.press,
  });

  Color get _statusColor {
    switch (status) {
      case 'A':
        return Colors.green.shade400;
      case 'C':
        return Colors.red.shade400;
      case 'NA':
        return Colors.yellow.shade400;
      case 'H':
        return Colors.orange.shade400;
      default:
        return Colors.yellow.shade400;
    }
  }

  String get _status {
    switch (status) {
      case 'A':
        return LocaleKeys.solved.tr();
      // case 'R':
      //   return LocaleKeys.rejected.tr();
      case 'NA':
        return LocaleKeys.pending.tr();
      case 'H':
        return LocaleKeys.on_hold.tr();
      case 'C':
        return LocaleKeys.closed.tr();
      default:
        return LocaleKeys.pending.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    // It  will provide us total height and width of our screen
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      // color: Colors.blueAccent,
      height: 120,
      child: InkWell(
        onTap: press,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            // Those are our background
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: _statusColor,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 15),
                      blurRadius: 27,
                      color: Colors.transparent // Black color with 12% opacity
                      )
                ],
              ),
              child: Container(
                margin: EdgeInsets.only(right: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: SizedBox(
                height: 180,
                width: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${LocaleKeys.complaint_id.tr()}: $complaintCode',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('${LocaleKeys.raised_by.tr()}: $name'),
                        subtitle: Text('${LocaleKeys.date.tr()}: $date'),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.symmetric(
                            horizontal: 15, // 30 padding
                            // vertical: 5, // 5 top and bottom
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(22),
                              topRight: Radius.circular(22),
                            ),
                          ),
                          child: Text(
                            _status,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            '${LocaleKeys.category.tr()}: $category',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

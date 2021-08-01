import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';

class RegistrationCard extends StatelessWidget {
  final int itemIndex;
  final String name;
  final String sevarthNumber;
  final String mobileNumber;
  final String division;
  final String designation;
  final String status;
  final Function press;
  RegistrationCard({
    this.itemIndex,
    this.name,
    this.sevarthNumber,
    this.division,
    this.mobileNumber,
    this.designation,
    this.status,
    this.press,
  });

  String _getStatus(String stat) {
    switch (stat) {
      case "NA":
        return LocaleKeys.pending.tr();
      case "A":
        return LocaleKeys.approved.tr();
      case "R":
        return LocaleKeys.rejected.tr();
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
                color: itemIndex.isEven ? Color(0xFF40BAD5) : Color(0xFFFFA41B),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 15),
                      blurRadius: 27,
                      color: Colors.transparent // Black color with 12% opacity
                      )
                ],
              ),
              child: Container(
                margin: EdgeInsets.only(right: 10),
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
                        '${LocaleKeys.sevarth_number.tr()}: $sevarthNumber',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('${LocaleKeys.name.tr()}: $name'),
                        subtitle:
                            Text('${LocaleKeys.work_office.tr()}: $division'),
                      ),
                    ),
                    Row(children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15, // 30 padding
                          vertical: 5, // 5 top and bottom
                        ),
                        decoration: BoxDecoration(
                          color: _getStatus(status) == LocaleKeys.approved.tr()
                              ? Colors.green.shade400
                              : _getStatus(status) == LocaleKeys.pending.tr()
                                  ? Colors.yellow.shade400
                                  : Colors.red.shade400,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                        ),
                        child: Text(
                          _getStatus(status),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                              "${LocaleKeys.designation.tr()} : $designation")),
                    ]),
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

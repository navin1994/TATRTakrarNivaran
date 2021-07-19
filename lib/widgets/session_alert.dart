import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/auth.dart';
import '../screens/login_signup_screen.dart';
import '../translations/locale_keys.g.dart';

class SessionAlert extends StatefulWidget {
  final String message;
  SessionAlert(this.message);

  @override
  _SessionAlertState createState() => _SessionAlertState();
}

class _SessionAlertState extends State<SessionAlert> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Icon(
        Icons.warning_rounded,
        size: 100,
        color: Colors.orange[300],
      ),
      content: Container(
        height: 60,
        child: Center(
          child: Text(
            widget.message,
            style: TextStyle(fontSize: 25),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            Navigator.of(context).pushNamedAndRemoveUntil(
                LoginSignupScreen.routeName, (route) => false);
            Provider.of<Auth>(context, listen: false).logout();
          }),
          child: Text(
            "${LocaleKeys.logout.tr()}",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

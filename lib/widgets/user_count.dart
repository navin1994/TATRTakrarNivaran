import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../screens/registration_List_screen.dart';
import '../translations/locale_keys.g.dart';

class UserCount extends StatelessWidget {
  final int count;
  const UserCount(this.count);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .pushNamed(RegistrationListScreen.routeName, arguments: 3),
      splashColor: Colors.pink,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.none,
                child: Text(
                  "$count",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            FittedBox(
              child: Text(
                LocaleKeys.total_users_under.tr(),
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

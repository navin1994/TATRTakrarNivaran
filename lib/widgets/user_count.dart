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
        margin: EdgeInsets.all(15),
        height: 100,
        width: 150,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                "$count",
                style: TextStyle(color: Colors.white, fontSize: 24),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.withOpacity(0.7), Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

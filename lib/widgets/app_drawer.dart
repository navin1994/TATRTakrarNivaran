import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';
import '../providers/auth.dart';
import '../screens/login_signup_screen.dart';
import '../screens/dashboard-screen.dart';
import '../screens/registration_List_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/complaint_management_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function closeDrawer;
  const AppDrawer({this.closeDrawer});
  @override
  Widget build(BuildContext context) {
    String _userName = Provider.of<Auth>(context, listen: false).name;
    return Container(
      width: MediaQuery.of(context).size.width * 0.68,
      child: Drawer(
        child: Container(
          color: Colors.lightGreen[50],
          child: ListView(
            children: [
              AppBar(
                brightness: Brightness.dark,
                centerTitle: true,
                backgroundColor: Colors.green[900],
                title: Text('${LocaleKeys.hello.tr()} $_userName'),
                automaticallyImplyLeading: false,
              ),
              Divider(
                height: 0.6,
                color: Colors.deepOrange,
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.pinkAccent[700]),
                tileColor: Colors.lightGreen[400],
                selectedTileColor: Colors.deepOrange,
                title: Text(
                  LocaleKeys.profile.tr(),
                  style: TextStyle(
                      color: Colors.teal[900], fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(ProfilePageScreen.routeName);
                  closeDrawer();
                },
              ),
              Divider(
                height: 0.6,
                color: Colors.deepOrange,
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.amber[900]),
                tileColor: Colors.lightGreen[300],
                title: Text(LocaleKeys.dashboard.tr(),
                    style: TextStyle(
                        color: Colors.teal[900], fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Dashboard.routeName, (route) => false);
                  closeDrawer();
                },
              ),
              Divider(
                height: 0.6,
                color: Colors.deepOrange,
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.green[900]),
                tileColor: Colors.lightGreen[400],
                title: Text(LocaleKeys.manage_complaints.tr(),
                    style: TextStyle(
                        color: Colors.teal[900], fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(ComplaintManagementScreen.routeName);
                  closeDrawer();
                },
              ),
              Divider(
                height: 0.8,
                color: Colors.deepOrange,
              ),
              ListTile(
                leading: Icon(Icons.app_registration, color: Colors.lime[900]),
                tileColor: Colors.lightGreen[300],
                title: Text(LocaleKeys.manage_registrations.tr(),
                    style: TextStyle(
                        color: Colors.green[900], fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(RegistrationListScreen.routeName);
                  closeDrawer();
                },
              ),
              Divider(
                height: 0.8,
                color: Colors.deepOrange,
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.deepOrange),
                tileColor: Colors.lightGreen[400],
                title: Text(LocaleKeys.logout.tr(),
                    style: TextStyle(
                        color: Colors.green[900], fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginSignupScreen.routeName, (route) => false);
                  Provider.of<Auth>(context, listen: false).logout();
                  closeDrawer();
                },
              ),
              Divider(
                height: 1,
                color: Colors.deepOrange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/login_signup_screen.dart';
import '../screens/dashboard-screen.dart';
import '../screens/registration_List_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/raise_complain_screen.dart';
import '../screens/complaint_management_screen.dart';
import '../screens/data_management_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String _userName = Provider.of<Auth>(context, listen: false).name;
    return Drawer(
      child: Container(
        child: ListView(
          children: [
            AppBar(
              title: Text('Hello $_userName'),
              automaticallyImplyLeading: false,
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(ProfilePageScreen.routeName);
              },
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(Dashboard.routeName);
              },
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Manage Complaints'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(ComplaintManagementScreen.routeName);
              },
            ),
            // Divider(
            //   height: 0.6,
            //   color: Colors.black87,
            // ),
            // ListTile(
            //   leading: Icon(Icons.add_comment),
            //   title: Text('New Complaint'),
            //   onTap: () {
            //     Navigator.of(context)
            //         .pushReplacementNamed(RaiseComplainScreen.routeName);
            //   },
            // ),
            // Divider(
            //   height: 0.6,
            //   color: Colors.black87,
            // ),
            // ListTile(
            //   leading: Icon(Icons.settings),
            //   title: Text('Data Management'),
            //   onTap: () {
            //     Navigator.of(context)
            //         .pushReplacementNamed(DataManagementScreen.routeName);
            //   },
            // ),
            // Divider(
            //   height: 0.6,
            //   color: Colors.black87,
            // ),
            // ListTile(
            //   leading: Icon(Icons.comment_bank),
            //   title: Text('My Complaints'),
            //   onTap: () {
            //     Navigator.of(context)
            //         .pushReplacementNamed(ComplaintManagementScreen.routeName);
            //   },
            // ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text('Manage Registrations'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(RegistrationListScreen.routeName);
              },
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushReplacementNamed(LoginSignupScreen.routeName);
                Provider.of<Auth>(context, listen: false).logout();
              },
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}

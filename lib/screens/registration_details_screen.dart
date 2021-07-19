import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';
import '../providers/registered_users.dart';
import '../models/registered_user.dart';
import '../widgets/session_alert.dart';

class RagistrationDetailsScreen extends StatelessWidget {
  static const routeName = '/registration-detail-screen';
// _getStatus() method to show registered user status
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
    // updateStatus() method updates the status of registered user
    Future<void> updateStatus(String stat, int userid) async {
      try {
        // call updateUserStatus() method of RegisteredUsers provider class
        final resp = await Provider.of<RegisteredUsers>(context, listen: false)
            .updateUserStatus(stat, userid);
        if (resp['Result'] == "OK") {
          // Show message if user status successfully updated
          SweetAlertV2.show(context,
              title: "${LocaleKeys.updated.tr()}!",
              subtitle: resp['Msg'],
              style: SweetAlertV2Style.success);
        } else if (resp['Result'] == "SESS") {
          return showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black45,
            builder: (context) => SessionAlert(resp['Msg']),
          );
        } else if (resp['Result'] == "NOK") {
          // Show message if any error occured while updating the registered user status
          SweetAlertV2.show(context,
              title: LocaleKeys.error.tr(),
              subtitle: resp['Msg'],
              style: SweetAlertV2Style.error);
        }
      } catch (error) {
        // Show message if any error occured while updating the registered user status
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_updating.tr(),
            style: SweetAlertV2Style.error);
      }
    }

    // Get registered user id through routing arguments to fetch selected user details
    final userId =
        ModalRoute.of(context).settings.arguments as int; // is the id!
    Widget _heading(String heading, RegisteredUser userData) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.80, //80% of width,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            heading,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15, // 30 padding
              vertical: 5, // 5 top and bottom
            ),
            decoration: BoxDecoration(
              // _getStatus() to get registered users current status background colour
              color: _getStatus(userData.stat) == LocaleKeys.approved.tr()
                  ? Colors.green.shade400
                  : _getStatus(userData.stat) == LocaleKeys.pending.tr()
                      ? Colors.yellow.shade400
                      : Colors.red.shade400,
              borderRadius: BorderRadius.all(
                Radius.circular(22),
              ),
            ),
            child: Text(
              // _getStatus() method to display registered user current status
              _getStatus(userData.stat),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ]),
      );
    }

    Widget _detailsCard(RegisteredUser userData) {
      return Container(
        margin: EdgeInsets.only(top: 10),
        height: MediaQuery.of(context).size.height * 0.70,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 4,
              child: Column(
                children: [
                  //row for each deatails
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                        "${LocaleKeys.sevarth_number.tr()}: ${userData.uSevarthNo}"),
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),

                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text(
                        "${LocaleKeys.registered_date.tr()}: ${userData.regon}"),
                  ),

                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(
                        "${LocaleKeys.mobile_no.tr()}: ${userData.uMobile}"),
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title:
                        Text("${LocaleKeys.email_id.tr()}: ${userData.uEmail}"),
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.badge),
                    title: Text(
                        "${LocaleKeys.designation.tr()}: ${userData.uDesgNm}"),
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(
                        "${LocaleKeys.work_office.tr()}: ${userData.uOfcNm}"),
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                        "${LocaleKeys.reporting_officer.tr()}: ${userData.uReportUNm}"),
                  ),

                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF581845),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xFF581845),
        elevation: 0,
        centerTitle: true,
        title: Text(LocaleKeys.registration_details.tr()),
      ),
      body: FutureBuilder(
        // call findById() method of RegisteredUsers provider class to get data of selected user
        future: Provider.of<RegisteredUsers>(context, listen: false)
            .findById(userId),
        builder: (ctx, resultSnapshot) => resultSnapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : Consumer<RegisteredUsers>(
                builder: (ctx, regUsers, _) => SafeArea(
                  bottom: false,
                  child: Center(
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            width: MediaQuery.of(context).size.width * 0.80,
                            child: Center(
                              child: Text(
                                '${regUsers.regUser.uFname} ${regUsers.regUser.uMname} ${regUsers.regUser.uLname}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          _heading(LocaleKeys.registration_details.tr(),
                              regUsers.regUser),
                          Expanded(
                            child: Stack(
                              children: [
                                // Our background
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 60),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF1EFF1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Align(
                                      alignment: FractionalOffset.bottomCenter,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Flexible(
                                            //  Button to update the status to registered user to approved
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors
                                                      .green, // background
                                                  onPrimary: Colors.white,
                                                  textStyle:
                                                      TextStyle(fontSize: 18)),
                                              label:
                                                  Text(LocaleKeys.apprv.tr()),
                                              icon: Icon(
                                                  Icons.check_circle_outline),
                                              onPressed: () => updateStatus(
                                                  "A", regUsers.regUser.uid),
                                            ),
                                          ),
                                          Flexible(
                                            //  Button to update the status to registered user to rejected
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                primary:
                                                    Colors.red, // background
                                                onPrimary:
                                                    Colors.white, // foreground
                                                textStyle:
                                                    TextStyle(fontSize: 18),
                                              ),
                                              icon: Icon(Icons.cancel_outlined),
                                              label: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Text(
                                                    LocaleKeys.reject.tr()),
                                              ),
                                              onPressed: () {
                                                updateStatus(
                                                    "R", regUsers.regUser.uid);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                _detailsCard(regUsers.regUser),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

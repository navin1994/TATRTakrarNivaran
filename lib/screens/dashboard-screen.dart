import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:swipedetector/swipedetector.dart';

import '../providers/auth.dart';
import '../models/filter_cmpl_args.dart';
import '../translations/locale_keys.g.dart';
import '../providers/complaints.dart';
import '../widgets/complaints_count.dart';
import '../widgets/session_alert.dart';
import '../widgets/user_count.dart';
import '../widgets/app_drawer.dart';
// import '../widgets/tile_widget.dart';
import '../screens/login_signup_screen.dart';
import '../screens/raise_complain_screen.dart';
import '../screens/complaint_management_screen.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FSBStatus drawerStatus;
  var _init = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      return;
    }
    checkAppUpdate();
    _getSummary();
    setState(() {
      _init = false;
    });
  }

  // Check app version details with server
  void checkAppUpdate() async {
    try {
      //  Call checkAppVersion() method of Auth provider class
      final res = await Provider.of<Auth>(context).checkAppVersion();
      if (res == null) {
        return;
      }
      // If Version is mismatched route on Login screen and logout the user
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginSignupScreen.routeName, (route) => false);
      // Logout the user if version is mismatched
      Provider.of<Auth>(context, listen: false).logout();
    } catch (error) {
      // Display error message if there is any error while checking app version
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_checking_app_version.tr(),
          style: SweetAlertV2Style.error);
    }
  }

  // Method to get the complaints summary for logged in user
  Future<void> _getSummary() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Call getComplaintSummary() method of Complaints provider class
      final result = await Provider.of<Complaints>(context, listen: false)
          .getComplaintSummary();
      setState(() {
        _isLoading = false;
      });
      if (result != null && result['Result'] == "NOK") {
        // Display error message if there is any error while getting complaints summary
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: result['Msg'],
            style: SweetAlertV2Style.error);
      } else if (result['Result'] == "SESS") {
        return showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black45,
          builder: (context) => SessionAlert(result['Msg']),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error != null) {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_getting_compl.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

  void _toggleAppDrawer() {
    setState(() {
      drawerStatus = drawerStatus == FSBStatus.FSB_OPEN
          ? FSBStatus.FSB_CLOSE
          : FSBStatus.FSB_OPEN;
    });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.do_you_really_want_to_exit.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(LocaleKeys.no.tr())),
          TextButton(
              onPressed: () {
                Provider.of<Auth>(context, listen: false).logout();
                Navigator.of(context).pop(true);
              },
              child: Text(LocaleKeys.yes.tr())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: true,
          backgroundColor: Colors.teal[900],
          leading:
              IconButton(onPressed: _toggleAppDrawer, icon: Icon(Icons.menu)),
          title: Text(
            LocaleKeys.dashboard.tr(),
          ),
        ),
        body: SwipeDetector(
          onSwipeLeft: _toggleAppDrawer,
          onSwipeRight: _toggleAppDrawer,
          child: FoldableSidebarBuilder(
            drawerBackgroundColor: Colors.teal[900],
            status: drawerStatus,
            drawer: AppDrawer(
              closeDrawer: () {
                setState(() {
                  drawerStatus = FSBStatus.FSB_CLOSE;
                });
              },
            ),
            screenContents: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.darken),
                      image: AssetImage("assets/images/bg3.jpg"),
                      fit: BoxFit.fill),
                ),
                width: double.infinity,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height - 130,
                              child: Consumer<Complaints>(
                                builder: (ctx, cmpl, _) =>
                                    SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (cmpl.reportingUsers > 0)
                                        UserCount(cmpl.reportingUsers),
                                      if (cmpl.reportingUsers > 0)
                                        Consumer<Complaints>(
                                          builder: (ctx, compl, _) => compl
                                                  .assignedToMe.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    LocaleKeys
                                                        .error_while_getting_assigned_to_me_complaint
                                                        .tr(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                )
                                              : ComplaintsCount(
                                                  LocaleKeys.alloted_to_me.tr(),
                                                  "AsnToMe",
                                                  compl.assignedToMe),
                                        ),
                                      if (cmpl.reportingUsers > 0)
                                        Consumer<Complaints>(
                                          builder: (ctx, compl, _) => compl
                                                  .underMyAuthority.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    LocaleKeys
                                                        .error_while_getting_under_my_authority_complaint
                                                        .tr(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                )
                                              : ComplaintsCount(
                                                  LocaleKeys.under_me.tr(),
                                                  "UndrMe",
                                                  compl.underMyAuthority),
                                        ),
                                      Consumer<Complaints>(
                                        builder: (ctx, compl, _) => compl
                                                .myComplaints.isEmpty
                                            ? Center(
                                                child: Text(
                                                  LocaleKeys
                                                      .error_while_getting_my_complaint_deails
                                                      .tr(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              )
                                            : ComplaintsCount(
                                                LocaleKeys.my_complaints.tr(),
                                                "Rsd",
                                                compl.myComplaints),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Button to navigate to the raise complaint screen
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 14),
                                      primary:
                                          Colors.deepOrange[900], // background
                                      onPrimary: Colors.white, // foreground
                                    ),
                                    onPressed: () => Navigator.of(context)
                                        .pushNamed(
                                            RaiseComplainScreen.routeName),
                                    child:
                                        Text(LocaleKeys.raise_complaint.tr()),
                                  ),
                                  SizedBox(width: 10),
                                  // Navigate to the complaint management screen on all complaints in my complaints
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 14),
                                      primary: Colors.green[900], // background
                                      onPrimary: Colors.white, // foreground
                                    ),
                                    onPressed: () => Navigator.of(context)
                                        .pushNamed(
                                            ComplaintManagementScreen.routeName,
                                            arguments: FilterComplaintArgs(
                                                indx: 7, srcUnder: "R")),
                                    child: Text(LocaleKeys.track_it.tr()),
                                  ),
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
      ),
    );
  }
}

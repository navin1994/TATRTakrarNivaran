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
import '../widgets/session_alert.dart';
import '../widgets/app_drawer.dart';
import '../widgets/tile_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      // backgroundColor: Color.fromRGBO(26, 29, 33, 1),
      // drawer: AppDrawer(),
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
          screenContents: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Consumer<Complaints>(
                  builder: (ctx, cmpl, _) => SafeArea(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.darken),
                            image: AssetImage("assets/images/bg3.jpg"),
                            fit: BoxFit.fill),
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * .80,
                            padding: EdgeInsets.all(10),
                            // If does not get the complaint summary display message
                            child: cmpl.complaintSummary.isEmpty
                                ? Center(
                                    child: Text(
                                        "${LocaleKeys.error_dashboard_summary.tr()}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22, color: Colors.white)))
                                : ListView(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(LocaleKeys.cmpl_data.tr(),
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white)),
                                          InkWell(
                                            // On clicking on text Navigate to the Complaint management screen
                                            child: Text(
                                                '${LocaleKeys.view_all_.tr()} >>',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white)),
                                            // Navigate to the complaint management screen with default filter
                                            onTap: () => Navigator.of(context)
                                                .pushNamed(
                                                    ComplaintManagementScreen
                                                        .routeName),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      InkWell(
                                        // Navigate to the complaint management screen on all complaints under my authority
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(
                                                ComplaintManagementScreen
                                                    .routeName,
                                                arguments: FilterComplaintArgs(
                                                    indx: 7, srcUnder: "A")),
                                        child: Tilewidget(
                                          color: Colors.yellow,
                                          symbol: cmpl.complaintSummary[0].text,
                                          icon: Icon(Icons.calculate_outlined,
                                              size: 32),
                                          perc: 100.0,
                                          textcolor: Colors.purpleAccent,
                                          count: int.parse(
                                              cmpl.complaintSummary[0].value),
                                        ),
                                      ),
                                      InkWell(
                                        // Navigate to the complaint management screen on approved complaints under my authority
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(
                                                ComplaintManagementScreen
                                                    .routeName,
                                                arguments: FilterComplaintArgs(
                                                    indx: 3, srcUnder: "A")),
                                        child: Tilewidget(
                                          color: Colors.greenAccent,
                                          symbol: cmpl.complaintSummary[1].text,
                                          icon: Icon(Icons.check_circle_outline,
                                              size: 32),
                                          perc: ((double.parse(cmpl
                                                      .complaintSummary[1]
                                                      .value) *
                                                  100) /
                                              double.parse(cmpl
                                                  .complaintSummary[0].value)),
                                          textcolor: Colors.greenAccent,
                                          count: int.parse(
                                              cmpl.complaintSummary[1].value),
                                        ),
                                      ),
                                      InkWell(
                                        // Navigate to the complaint management screen on pending complaints under my authority
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(
                                                ComplaintManagementScreen
                                                    .routeName,
                                                arguments: FilterComplaintArgs(
                                                    indx: 1, srcUnder: "A")),
                                        child: Tilewidget(
                                          color: Colors.orange,
                                          symbol: cmpl.complaintSummary[3].text,
                                          icon: Icon(Icons.pending_actions,
                                              size: 32),
                                          perc: ((double.parse(cmpl
                                                      .complaintSummary[3]
                                                      .value) *
                                                  100) /
                                              double.parse(cmpl
                                                  .complaintSummary[0].value)),
                                          textcolor: Colors.amberAccent,
                                          count: int.parse(
                                              cmpl.complaintSummary[3].value),
                                        ),
                                      ),
                                      InkWell(
                                        // Navigate to the complaint management screen on rejected complaints under my authority
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(
                                                ComplaintManagementScreen
                                                    .routeName,
                                                arguments: FilterComplaintArgs(
                                                    indx: 4, srcUnder: "A")),
                                        child: Tilewidget(
                                          color: Colors.red,
                                          symbol: cmpl.complaintSummary[2].text,
                                          icon: Icon(
                                              Icons.close_fullscreen_outlined,
                                              size: 32),
                                          perc: ((double.parse(cmpl
                                                      .complaintSummary[2]
                                                      .value) *
                                                  100) /
                                              double.parse(cmpl
                                                  .complaintSummary[0].value)),
                                          textcolor: Colors.redAccent,
                                          count: int.parse(
                                              cmpl.complaintSummary[2].value),
                                        ),
                                      ),
                                      InkWell(
                                        // Navigate to the complaint management screen on approved complaints under my authority
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(
                                                ComplaintManagementScreen
                                                    .routeName,
                                                arguments: FilterComplaintArgs(
                                                    indx: 5, srcUnder: "A")),
                                        child: Tilewidget(
                                          color: Colors.purpleAccent,
                                          symbol: cmpl.complaintSummary[5].text,
                                          icon: Icon(
                                              Icons.pause_circle_outline_sharp,
                                              size: 32),
                                          perc: ((double.parse(cmpl
                                                      .complaintSummary[5]
                                                      .value) *
                                                  100) /
                                              double.parse(cmpl
                                                  .complaintSummary[0].value)),
                                          textcolor: Colors.blueAccent,
                                          count: int.parse(
                                              cmpl.complaintSummary[5].value),
                                        ),
                                      ),
                                      InkWell(
                                        // Navigate to the complaint management screen on approved complaints under my authority
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(
                                                ComplaintManagementScreen
                                                    .routeName,
                                                arguments: FilterComplaintArgs(
                                                    indx: 6, srcUnder: "A")),
                                        child: Tilewidget(
                                          color: Colors.pinkAccent,
                                          symbol: cmpl.complaintSummary[4].text,
                                          icon: Icon(
                                              Icons.do_not_disturb_alt_outlined,
                                              size: 32),
                                          perc: ((double.parse(cmpl
                                                      .complaintSummary[4]
                                                      .value) *
                                                  100) /
                                              double.parse(cmpl
                                                  .complaintSummary[0].value)),
                                          textcolor: Colors.pinkAccent,
                                          count: int.parse(
                                              cmpl.complaintSummary[4].value),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(
                            // width: double.infinity,
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
                                      .pushNamed(RaiseComplainScreen.routeName),
                                  child: Text(LocaleKeys.raise_complaint.tr()),
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
    );
  }
}

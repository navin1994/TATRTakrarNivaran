import 'package:flutter/material.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:swipedetector/swipedetector.dart';

import '../translations/locale_keys.g.dart';
import '../providers/registered_users.dart';
import '../widgets/show_list.dart';
import '../widgets/app_drawer.dart';
import '../widgets/filter_list.dart';

class RegistrationListScreen extends StatefulWidget {
  static const routeName = '/registration-list-screen';

  @override
  _RegistrationListScreenState createState() => _RegistrationListScreenState();
}

class _RegistrationListScreenState extends State<RegistrationListScreen> {
  FSBStatus drawerStatus;
  final String _listType = "users";
  // Default criteria is pending
  String _crit = "NA";
  // Status filter list it's sequence should be matched with _filterData()
  final List _filters = [
    LocaleKeys.pending.tr(),
    LocaleKeys.approved.tr(),
    LocaleKeys.rejected.tr(),
    LocaleKeys.reporting.tr()
  ];
  var _selectedIndex = 0;
  // Fetch data based on fliter value selected according to index
  // it's sequence should be matched with _filters List
  void _filterData(index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
      case 0:
        setState(() {
          // Fetch pending status users
          _crit = "NA";
        });
        break;
      case 1:
        setState(() {
          // Fetch approved status users
          _crit = "A";
        });
        break;
      case 2:
        setState(() {
          // Fetch Rejected status users
          _crit = "R";
        });
        break;
      case 3:
        setState(() {
          // Fetch Reporting users list
          _crit = "AU";
        });
        break;
      default:
        setState(() {
          // Fetch pending users list
          _crit = "NA";
        });
    }
  }

// _fetchAndSetRegistrations() method to fetch Registered users from server
  Future<void> _fetchAndSetRegistrations(String filterValue) async {
    try {
      // call fetchAndSetRegisteredUsers() method of RegisteredUsers provider class
      final response =
          await Provider.of<RegisteredUsers>(context, listen: false)
              .fetchAndSetRegisteredUsers(filterValue);
      if (response != 0) {
        // Show message if any error occured while fetching the Registered users
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: response,
            style: SweetAlertV2Style.error);
        return;
      }
    } catch (error) {
      if (error != null) {
        // Show message if any error occured while fetching the Registered users
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_loading_reg.tr(),
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
      backgroundColor: Color(0xFF581845),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xFF581845),
        elevation: 0,
        centerTitle: true,
        leading:
            IconButton(onPressed: _toggleAppDrawer, icon: Icon(Icons.menu)),
        title: Text(LocaleKeys.registration_list.tr()),
      ),
      // drawer: AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: SwipeDetector(
          onSwipeLeft: _toggleAppDrawer,
          onSwipeRight: _toggleAppDrawer,
          child: FoldableSidebarBuilder(
            drawerBackgroundColor: Color(0xFF581845),
            status: drawerStatus,
            drawer: AppDrawer(
              closeDrawer: () {
                setState(() {
                  drawerStatus = FSBStatus.FSB_CLOSE;
                });
              },
            ),
            screenContents: Container(
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //       image: AssetImage("assets/images/background-waterfall.jpg"),
              //       fit: BoxFit.fill),
              // ),
              child: Column(
                children: <Widget>[
                  // SearchBox(),
                  FilterList(_filters, _filterData, _selectedIndex),
                  SizedBox(height: 10),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        // Our background
                        Container(
                          margin: EdgeInsets.only(top: 60),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1EFF1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                        ),
                        FutureBuilder(
                            // Fetch registered user list based on selected filter criteria
                            future: _fetchAndSetRegistrations(_crit),
                            builder: (ctx, resultSnapshot) =>
                                resultSnapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ShowList(_listType)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

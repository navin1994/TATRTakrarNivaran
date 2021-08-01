import 'package:flutter/material.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:swipedetector/swipedetector.dart';

import '../models/filter_cmpl_args.dart';
import '../translations/locale_keys.g.dart';
import '../widgets/show_list.dart';
import '../widgets/filter_list.dart';
import '../widgets/search_box.dart';
import '../widgets/app_drawer.dart';
import '../widgets/session_alert.dart';
import '../providers/complaints.dart';
import '../screens/raise_complain_screen.dart';

class ComplaintManagementScreen extends StatefulWidget {
  static const routeName = '/complaint-management-screen';

  @override
  _ComplaintManagementScreenState createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen> {
  FSBStatus drawerStatus;
  // _isLoading is used to show circular progrss indicator while screen is loading
  var _isLoading = false;
  // _init is used to control the didChangeDependencies() methods executions
  var _init = true;
  // _crit is used to maintain the filter state
  String _crit = "PM";
  final String _listType = "complaints";
  // Please match sequence with _filterData method
  final List _filters = [
    LocaleKeys.my_complaints.tr(),
    LocaleKeys.pending_with_me.tr(),
    LocaleKeys.in_progress.tr(),
    LocaleKeys.solved.tr(),
    LocaleKeys.closed.tr(),
    LocaleKeys.on_hold.tr(),
    LocaleKeys.transfered.tr(),
    LocaleKeys.all.tr()
  ];
  // _selectedIndex is used to maintain the selected index of filter state
  var _selectedIndex = 1;
  // _srchUnder is used to maintain the value of dropdown selection
  var _srchUnder = "A";
  // Please match sequence with _filters variable
  void _filterData(index) {
    _selectedIndex = index;
    // Fetch the complaint based on filter and dropdown selection value from server
    switch (_selectedIndex) {
      case 0:
        // Fetch my complaints
        _fetchAndSetComplaints("IP", true, inclUndr: _srchUnder);
        break;
      case 1:
        // Fetch pending with me complaints
        _fetchAndSetComplaints("PM", true, inclUndr: _srchUnder);
        break;
      case 2:
        // Fetch in progress complaints
        _fetchAndSetComplaints("IP", true, inclUndr: _srchUnder);
        break;
      case 3:
        // Fetch solved complaints
        _fetchAndSetComplaints("A", true, inclUndr: _srchUnder);
        break;
      case 4:
        // Fetch closed complaints
        _fetchAndSetComplaints("C", true, inclUndr: _srchUnder);
        break;
      case 5:
        // Fetch on hold complaints
        _fetchAndSetComplaints("H", true, inclUndr: _srchUnder);
        break;
      case 6:
        // Fetche transfer to higher authority complaints
        _fetchAndSetComplaints("AH", true, inclUndr: _srchUnder);
        break;
      default:
        // Fetch all raised complaints
        _fetchAndSetComplaints("AL", true, inclUndr: _srchUnder);
    }
  }

// This method is used to search the complaints based on filter criteria
  void _searchFeature(String srcCmpno, inclUndr) {
    if (srcCmpno != null && inclUndr != null) {
      setState(() {
        _selectedIndex = 5;
        _crit = "AR";
      });
      _fetchAndSetComplaints(_crit, true,
          srcCmpno: srcCmpno, inclUndr: inclUndr);
    } else {
      SweetAlertV2.show(
        context,
        title: LocaleKeys.error.tr(),
        subtitle: LocaleKeys.please_enter_compl.tr(),
        style: SweetAlertV2Style.error,
      );
    }
  }

  // _dropdownChangeFilter() method is used fetch data on changing the value of dropdown
  void _dropdownChangeFilter(String includUnder) {
    _srchUnder = includUnder;
    _filterData(_selectedIndex);
  }

// Fetch complaints based on provided values
  Future<void> _fetchAndSetComplaints(String filterValue, bool isSearch,
      {String srcCmpno, String inclUndr}) async {
    try {
      var response;
      if (filterValue == "Y") {
        setState(() {
          _crit = filterValue;
          _isLoading = true;
        });
        response = await Provider.of<Complaints>(context, listen: false)
            .fetchAndSetcomplaints(filterValue);
      } else {
        setState(() {
          _crit = filterValue;
          _isLoading = true;
        });
        response = await Provider.of<Complaints>(context, listen: false)
            .serachComplaint(filterValue, srcCmpno, inclUndr);
      }
      setState(() {
        _isLoading = false;
      });
      if (response['Result'] == "NOK") {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: response['Msg'],
            style: SweetAlertV2Style.error);
      } else if (response['Result'] == "SESS") {
        return showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black45,
          builder: (context) => SessionAlert(response['Msg']),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error != null) {
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
  void didChangeDependencies() {
    if (!_init) {
      return;
    }
    //  Fetch value based on routing arguments filterwise
    final trackIt =
        ModalRoute.of(context).settings.arguments as FilterComplaintArgs;
    if (trackIt != null) {
      setState(() {
        _srchUnder = trackIt.srcUnder;
        _init = false;
      });
      _filterData(trackIt.indx);
      return;
    }
    _filterData(_selectedIndex);
    setState(() {
      _init = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Get the device screen size
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFF581845),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xFF581845),
        elevation: 0,
        centerTitle: true,
        leading:
            IconButton(onPressed: _toggleAppDrawer, icon: Icon(Icons.menu)),
        title: Text(
          LocaleKeys.complt_mngmnt.tr(),
        ),
      ),
      // GestureDetector to hide the keypad on clicking outside of input field
      body: SwipeDetector(
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
          screenContents: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SafeArea(
              bottom: false,
              child: Container(
                height: screenSize.height,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //       image: AssetImage("assets/images/background-waterfall.jpg"),
                //       fit: BoxFit.fill),
                // ),
                child: Column(
                  children: <Widget>[
                    // Search Box widget
                    SearchBox(
                        _searchFeature, _srchUnder, _dropdownChangeFilter),

                    // Filter list widget
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
                          _isLoading
                              ? Center(
                                  // Circular progress indicator to show loading screen
                                  child: CircularProgressIndicator(),
                                )
                              // Show list of complaints
                              : ShowList(_listType),
                          Padding(
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            child: Align(
                              alignment: FractionalOffset.bottomRight,
                              child: FloatingActionButton(
                                backgroundColor: Colors.deepOrange[900],
                                elevation: 40,
                                child: Icon(
                                  Icons.add,
                                  size: 35,
                                ),
                                // Create complaint screen navigation
                                onPressed: () => Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, _) {
                                      return RaiseComplainScreen();
                                    },
                                    opaque: false,
                                  ),
                                ),
                              ),
                            ),
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

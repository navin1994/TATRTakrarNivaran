import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';
import '../widgets/show_list.dart';
import '../widgets/filter_list.dart';
import '../widgets/search_box.dart';
import '../widgets/app_drawer.dart';
import '../providers/complaints.dart';
import '../screens/raise_complain_screen.dart';

class ComplaintManagementScreen extends StatefulWidget {
  static const routeName = '/complaint-management-screen';

  @override
  _ComplaintManagementScreenState createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen> {
  var _isLoading = false;
  var _init = true;
  String _crit = "NA";
  final String _listType = "complaints";
  final List _filters = [
    LocaleKeys.my_complaints.tr(),
    LocaleKeys.pending.tr(),
    LocaleKeys.on_hold,
    LocaleKeys.approved.tr(),
    LocaleKeys.rejected.tr(),
    LocaleKeys.all.tr()
  ];
  var _selectedIndex = 1;
  void _filterData(index) {
    _selectedIndex = index;
    switch (_selectedIndex) {
      case 0:
        _fetchAndSetComplaints("Y", false);
        break;
      case 1:
        _fetchAndSetComplaints("NA", false);
        break;
      case 2:
        _fetchAndSetComplaints("H", false);
        break;
      case 3:
        _fetchAndSetComplaints("A", false);
        break;
      case 4:
        _fetchAndSetComplaints("R", false);
        break;
      default:
        _fetchAndSetComplaints("AR", false);
    }
  }

  void _searchFeature(int srcCmpno, inclUndr) {
    if (srcCmpno != null && inclUndr != null) {
      _fetchAndSetComplaints(_crit, true,
          srcCmpno: srcCmpno, inclUndr: inclUndr);
    } else {
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.please_enter_compl.tr(),
          style: SweetAlertV2Style.error);
    }
  }

  Future<void> _fetchAndSetComplaints(String filterValue, bool isSearch,
      {int srcCmpno, String inclUndr}) async {
    try {
      var response;
      if (!isSearch) {
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
      if (response['Result'] != "OK") {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: response['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error ===> $error");
      if (error != null) {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_loading_reg.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (!_init) {
      return;
    }
    _fetchAndSetComplaints("NA", false);
    setState(() {
      _init = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.complt_mngmnt.tr(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment_outlined),
            padding: EdgeInsets.all(10),
            iconSize: 34,
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pushNamed(RaiseComplainScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: new GestureDetector(
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
                SearchBox(_searchFeature),
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
                              child: CircularProgressIndicator(),
                            )
                          : ShowList(_listType),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

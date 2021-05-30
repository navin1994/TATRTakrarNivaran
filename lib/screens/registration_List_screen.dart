import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';

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
  final String _listType = "users";
  String _crit = "NA";
  final List _filters = [
    LocaleKeys.pending.tr(),
    LocaleKeys.approved.tr(),
    LocaleKeys.rejected.tr(),
    LocaleKeys.reporting.tr()
  ];
  var _selectedIndex = 0;
  void _filterData(index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
      case 0:
        setState(() {
          _crit = "NA";
        });
        break;
      case 1:
        setState(() {
          _crit = "A";
        });
        break;
      case 2:
        setState(() {
          _crit = "R";
        });
        break;
      case 3:
        setState(() {
          _crit = "AU";
        });
        break;
      default:
        setState(() {
          _crit = "NA";
        });
    }
  }

  Future<void> _fetchAndSetRegistrations(String filterValue) async {
    try {
      final response =
          await Provider.of<RegisteredUsers>(context, listen: false)
              .fetchAndSetRegisteredUsers(filterValue);
      if (response != 0) {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: response,
            style: SweetAlertV2Style.error);
        return;
      }
    } catch (error) {
      if (error != null) {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_loading_reg.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF035AA6),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xFF035AA6),
        elevation: 0,
        centerTitle: true,
        title: Text(LocaleKeys.registration_list.tr()),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: Container(
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
    );
  }
}

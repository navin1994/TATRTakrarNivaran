import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';
import '../providers/complaints.dart';
import '../widgets/app_drawer.dart';
import '../widgets/tile_widget.dart';
// import '../widgets/pending_complaint_card.dart';
import '../screens/complaint_management_screen.dart';

class Dashboard extends StatelessWidget {
  static const routeName = '/dashboard';
  @override
  Widget build(BuildContext context) {
    Future<void> _getSummary() async {
      try {
        final result =
            await Provider.of<Complaints>(context).getComplaintSummary();
        if (result != null && result['Result'] == "NOK") {
          SweetAlertV2.show(context,
              title: LocaleKeys.error.tr(),
              subtitle: result['Msg'],
              style: SweetAlertV2Style.error);
        }
      } catch (error) {
        print("Error ==> $error");
        if (error != null) {
          SweetAlertV2.show(context,
              title: LocaleKeys.error.tr(),
              subtitle: LocaleKeys.error_while_getting_compl.tr(),
              style: SweetAlertV2Style.error);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          LocaleKeys.dashboard.tr(),
        ),
      ),
      backgroundColor: Color.fromRGBO(26, 29, 33, 1),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _getSummary(),
        builder: (ctx, resultSnapshot) => resultSnapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<Complaints>(
                builder: (ctx, cmpl, _) => SafeArea(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: cmpl.complaintSummary.isEmpty
                        ? Center(
                            child: Text(
                                "${LocaleKeys.error_dashboard_summary.tr()}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white)))
                        : ListView(
                            children: [
                              // Text('Pending Complaints',
                              //     style: TextStyle(fontSize: 22, color: Colors.white)),
                              // SizedBox(height: 10),
                              // PendingComplaintCard(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(LocaleKeys.cmpl_data.tr(),
                                      style: TextStyle(
                                          fontSize: 22, color: Colors.white)),
                                  InkWell(
                                    child: Text(
                                        '${LocaleKeys.view_all_.tr()} >>',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white)),
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                              ComplaintManagementScreen
                                                  .routeName);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacementNamed(
                                      ComplaintManagementScreen.routeName,
                                      arguments: 5);
                                },
                                child: Tilewidget(
                                  color: Colors.yellow,
                                  symbol: cmpl.complaintSummary[0].text,
                                  icon:
                                      Icon(Icons.calculate_outlined, size: 32),
                                  perc: 100.0,
                                  textcolor: Colors.purpleAccent,
                                  count:
                                      int.parse(cmpl.complaintSummary[0].value),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacementNamed(
                                      ComplaintManagementScreen.routeName,
                                      arguments: 3);
                                },
                                child: Tilewidget(
                                  color: Colors.greenAccent,
                                  symbol: cmpl.complaintSummary[1].text,
                                  icon: Icon(Icons.check_circle_outline,
                                      size: 32),
                                  perc: ((double.parse(
                                              cmpl.complaintSummary[1].value) *
                                          100) /
                                      double.parse(
                                          cmpl.complaintSummary[0].value)),
                                  textcolor: Colors.greenAccent,
                                  count:
                                      int.parse(cmpl.complaintSummary[1].value),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacementNamed(
                                      ComplaintManagementScreen.routeName,
                                      arguments: 1);
                                },
                                child: Tilewidget(
                                  color: Colors.orange,
                                  symbol: cmpl.complaintSummary[3].text,
                                  icon: Icon(Icons.pending_actions, size: 32),
                                  perc: ((double.parse(
                                              cmpl.complaintSummary[3].value) *
                                          100) /
                                      double.parse(
                                          cmpl.complaintSummary[0].value)),
                                  textcolor: Colors.amberAccent,
                                  count:
                                      int.parse(cmpl.complaintSummary[3].value),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacementNamed(
                                      ComplaintManagementScreen.routeName,
                                      arguments: 4);
                                },
                                child: Tilewidget(
                                  color: Colors.red,
                                  symbol: cmpl.complaintSummary[2].text,
                                  icon: Icon(Icons.highlight_remove_outlined,
                                      size: 32),
                                  perc: ((double.parse(
                                              cmpl.complaintSummary[2].value) *
                                          100) /
                                      double.parse(
                                          cmpl.complaintSummary[0].value)),
                                  textcolor: Colors.redAccent,
                                  count:
                                      int.parse(cmpl.complaintSummary[2].value),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}

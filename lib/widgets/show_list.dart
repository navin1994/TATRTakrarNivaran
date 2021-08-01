import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';
import '../screens/complaint_details_screen.dart';
import '../screens/registration_details_screen.dart';
import 'complaints_card.dart';
import 'registration_card.dart';
import '../providers/registered_users.dart';
import '../providers/complaints.dart';

class ShowList extends StatefulWidget {
  final String listType;

  ShowList(this.listType);

  @override
  _ShowListState createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  ScrollController cmplScrollCtrl = ScrollController();
  ScrollController regScrollController = ScrollController();
  double topContainer = 0;

  @override
  void initState() {
    super.initState();
    cmplScrollCtrl.addListener(() {
      double value = cmplScrollCtrl.offset / 126;
      setState(() {
        topContainer = value;
      });
    });
    regScrollController.addListener(() {
      double value = regScrollController.offset / 126;
      setState(() {
        topContainer = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cmplScrollCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.listType == "complaints"
        ? Consumer<Complaints>(
            builder: (ctx, cmp, _) => cmp.complaints.length <= 0
                ? Center(
                    child: Text(LocaleKeys.cmpl_not_avlbl.tr()),
                  )
                : ListView.builder(
                    controller: cmplScrollCtrl,
                    physics: BouncingScrollPhysics(),
                    itemCount: cmp.complaints.length,
                    itemBuilder: (context, index) {
                      double scale = 1.0;
                      if (topContainer > 0.5) {
                        scale = index + 0.5 - topContainer;
                        if (scale < 0) {
                          scale = 0;
                        } else if (scale > 1) {
                          scale = 1;
                        }
                      }
                      return Transform(
                        transform: Matrix4.identity()..scale(scale, scale),
                        child: Align(
                          heightFactor: 0.9,
                          alignment: Alignment.topCenter,
                          child: ComplaintCard(
                            itemIndex: index,
                            name: cmp.complaints[index].regby,
                            complaintCode: cmp.complaints[index].cmpId,
                            date: cmp.complaints[index].regon,
                            category: cmp.complaints[index].cmpCat,
                            status: cmp.complaints[index].stat,
                            press: () {
                              Navigator.of(context).pushNamed(
                                  ComplaintDetailsScreen.routeName,
                                  arguments: cmp.complaints[index].cmpId);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          )
        : Consumer<RegisteredUsers>(
            builder: (ctx, users, _) => users.registeredUsers.length <= 0
                ? Center(
                    child: Text(LocaleKeys.users_not_available.tr()),
                  )
                : ListView.builder(
                    controller: regScrollController,
                    physics: BouncingScrollPhysics(),
                    itemCount: users.registeredUsers.length,
                    itemBuilder: (context, index) {
                      double scale = 1.0;
                      if (topContainer > 0.5) {
                        scale = index + 0.5 - topContainer;
                        if (scale < 0) {
                          scale = 0;
                        } else if (scale > 1) {
                          scale = 1;
                        }
                      }
                      return Transform(
                        transform: Matrix4.identity()..scale(scale, scale),
                        child: Align(
                          heightFactor: 0.9,
                          alignment: Alignment.topCenter,
                          child: RegistrationCard(
                            itemIndex: index,
                            name:
                                "${users.registeredUsers[index].uFname} ${users.registeredUsers[index].uMname} ${users.registeredUsers[index].uLname}",
                            sevarthNumber:
                                users.registeredUsers[index].uSevarthNo,
                            division: users.registeredUsers[index].uOfcNm,
                            mobileNumber: users.registeredUsers[index].uMobile,
                            designation: users.registeredUsers[index].uDesgNm,
                            status: users.registeredUsers[index].stat,
                            press: () {
                              Navigator.of(context).pushNamed(
                                  RagistrationDetailsScreen.routeName,
                                  arguments: users.registeredUsers[index].uid);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          );
  }
}

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

class ShowList extends StatelessWidget {
  final String listType;

  ShowList(this.listType);

  @override
  Widget build(BuildContext context) {
    return listType == "complaints"
        ? Consumer<Complaints>(
            builder: (ctx, cmp, _) => cmp.complaints.length <= 0
                ? Center(
                    child: Text(LocaleKeys.cmpl_not_avlbl.tr()),
                  )
                : ListView.builder(
                    itemCount: cmp.complaints.length,
                    itemBuilder: (context, index) => ComplaintCard(
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
          )
        : Consumer<RegisteredUsers>(
            builder: (ctx, users, _) => users.registeredUsers.length <= 0
                ? Center(
                    child: Text(LocaleKeys.users_not_available.tr()),
                  )
                : ListView.builder(
                    itemCount: users.registeredUsers.length,
                    itemBuilder: (context, index) => RegistrationCard(
                      itemIndex: index,
                      name:
                          "${users.registeredUsers[index].uFname} ${users.registeredUsers[index].uLname}",
                      sevarthNumber: users.registeredUsers[index].uSevarthNo,
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
  }
}

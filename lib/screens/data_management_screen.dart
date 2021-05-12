import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../widgets/add_category.dart';
import '../widgets/add_user_type.dart';
import '../widgets/add_range.dart';

class DataManagementScreen extends StatelessWidget {
  static const routeName = '/data-management-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('Data Management'),
      ),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.black12,
          //     image: DecorationImage(
          //         image: AssetImage("assets/images/background-forest.jpg"),
          //         fit: BoxFit.fill),
          //     borderRadius: BorderRadius.only(
          //         bottomLeft: Radius.circular(50),
          //         bottomRight: Radius.circular(50)),
          //   ),
          //   height: MediaQuery.of(context).size.height * .35,
          // ),
          Container(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    AddUserType(),
                    AddCategory(),
                    AddRange(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

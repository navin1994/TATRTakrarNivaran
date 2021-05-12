import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/LOGO-of-MFD-VAN-VIBHAG.jpg"),
              fit: BoxFit.fill),
        ),
      )),
    );
  }
}

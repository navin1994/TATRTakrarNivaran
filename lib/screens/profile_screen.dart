import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';

import '../models/profile.dart';
import '../widgets/app_drawer.dart';
import '../config/palette.dart';
import '../widgets/form_field.dart' as padding;
import '../widgets/change_password.dart';
import '../providers/auth.dart';

class ProfilePageScreen extends StatefulWidget {
  static const routeName = 'profile-page-screen';
  @override
  _ProfilePageScreenState createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  var _pwdchng = false;
  var _isLoading = false;
  var _isInit = true;
  bool _isEditable = false;
  final _profileForm = GlobalKey<FormState>();
  String fName, lName, email, mobile;

  void _toggleEdit() {
    setState(() {
      _isEditable = !_isEditable;
    });
  }

  void _togglePwdChange() {
    setState(() {
      _pwdchng = !_pwdchng;
    });
  }

  Future<void> getUserPrfile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final resp = await Provider.of<Auth>(context, listen: false).getProfile();
      setState(() {
        _isLoading = false;
      });
      if (resp['Result'] != "OK") {
        SweetAlertV2.show(context,
            title: "Saved",
            subtitle: resp['Msg'],
            style: SweetAlertV2Style.success);
      }
    } catch (error) {
      print("Error ==> $error");
      if (error != null) {
        SweetAlertV2.show(context,
            title: "Error",
            subtitle: "Error while getting profile data.",
            style: SweetAlertV2Style.error);
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      return;
    }
    getUserPrfile();
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _submitUpdateProfileForm() async {
    final isValid = _profileForm.currentState
        .validate(); // this will trigger validator on each textFormField
    if (!isValid) {
      return;
    }
    _profileForm.currentState.save();
    try {
      setState(() {
        _isLoading = true;
      });
      final respo = await Provider.of<Auth>(context, listen: false)
          .updateProfile(fName, lName, mobile, email);
      setState(() {
        _isLoading = false;
      });
      print("Response ===> ${respo["Result"]}");
      if (respo["Result"] == "OK") {
        setState(() {
          _isEditable = false;
        });
        SweetAlertV2.show(context,
            title: "Saved!",
            subtitle: respo['Msg'],
            style: SweetAlertV2Style.success);
      } else {
        SweetAlertV2.show(context,
            title: "Error",
            subtitle: respo['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      if (error != null) {
        print("Error ===> $error");
        SweetAlertV2.show(context,
            title: "Error",
            subtitle: "Error while updating profile data.",
            style: SweetAlertV2Style.error);
      }
    }
  }

  InputDecoration decoration({IconData icon, String hintText}) {
    return InputDecoration(
      labelText: hintText,
      prefixIcon: Icon(
        icon,
        color: Palette.iconColor,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Palette.textColor1),
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Palette.textColor1),
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
      ),
      contentPadding: EdgeInsets.all(10),
      // hintText: hintText,
      hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
    );
  }

  dynamic dropdownBuilder(List<String> items) {
    return items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Profile profile =
        Provider.of<Auth>(context, listen: false).userProfile;
    Widget _heading(String heading) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.80, //80% of width,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            heading,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (_isEditable)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 12,
                primary: Colors.red, // background
                onPrimary: Colors.white, // foreground
              ),
              onPressed: _toggleEdit,
              icon: Icon(Icons.edit_off),
              label: Text('Cancel'),
            ),
          if (!_isEditable)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 12,
                primary: Colors.pink.shade300, // background
                onPrimary: Colors.white, // foreground
              ),
              onPressed: _toggleEdit,
              icon: Icon(Icons.edit),
              label: Text('Edit'),
            ),
        ]),
      );
    }

    Widget _detailsCard() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _profileForm,
          child: Card(
            elevation: 12,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_isEditable)
                    SizedBox(
                      height: 10,
                    ),
                  if (_isEditable)
                    padding.FormFieldWidget(
                      TextFormField(
                        initialValue: profile.uFname,
                        keyboardType: TextInputType.text,
                        decoration: decoration(hintText: 'First Name'),
                        onSaved: (firstName) {
                          setState(() {
                            fName = firstName;
                          });
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                    ),
                  if (_isEditable)
                    padding.FormFieldWidget(
                      TextFormField(
                        initialValue: profile.uLname,
                        keyboardType: TextInputType.text,
                        decoration: decoration(hintText: 'Last Name'),
                        onSaved: (lastName) {
                          setState(() {
                            lName = lastName;
                          });
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter last name.';
                          }
                          return null;
                        },
                      ),
                    ),
                  if (!_isEditable)
                    ListTile(
                      leading: Icon(Icons.badge),
                      title: Text("Designation: ${profile.uDesgNm}"),
                    ),
                  if (!_isEditable)
                    Divider(
                      height: 0.6,
                      color: Colors.black87,
                    ),
                  if (!_isEditable)
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Sevarth Number: ${profile.uSevarthNo}"),
                    ),
                  if (!_isEditable)
                    Divider(
                      height: 0.6,
                      color: Colors.black87,
                    ),
                  if (_isEditable)
                    padding.FormFieldWidget(
                      TextFormField(
                        initialValue: profile.uEmail,
                        keyboardType: TextInputType.text,
                        decoration: decoration(hintText: 'Email Id'),
                        onSaved: (eMail) {
                          setState(() {
                            email = eMail;
                          });
                        },
                      ),
                    ),
                  if (!_isEditable)
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text("Mobile No.: ${profile.uMobile}"),
                    ),
                  if (!_isEditable)
                    Divider(
                      height: 0.6,
                      color: Colors.black87,
                    ),
                  if (_isEditable)
                    padding.FormFieldWidget(
                      TextFormField(
                        initialValue: profile.uMobile,
                        keyboardType: TextInputType.number,
                        decoration: decoration(hintText: 'Mobile Number'),
                        onSaved: (mobileNo) {
                          setState(() {
                            mobile = mobileNo;
                          });
                        },
                        validator: (value) {
                          String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                          RegExp regExp = new RegExp(patttern);

                          if (!regExp.hasMatch(value) && value != null) {
                            return 'Please enter valid mobile number.';
                          }
                          return null;
                        },
                      ),
                    ),
                  if (!_isEditable)
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text("Email Id: ${profile.uEmail}"),
                    ),
                  if (!_isEditable)
                    Divider(
                      height: 0.6,
                      color: Colors.black87,
                    ),
                  if (!_isEditable)
                    ListTile(
                      leading: Icon(Icons.design_services_outlined),
                      title: Text("Work Office: ${profile.uOfcNm}"),
                    ),
                  if (!_isEditable)
                    Divider(
                      height: 0.6,
                      color: Colors.black87,
                    ),
                  if (!_isEditable)
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Reporting To: ${profile.uReportUNm}"),
                    ),
                  if (_isEditable)
                    SizedBox(
                      height: 10,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: Text('User Profile'),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Container(
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     begin: Alignment.topRight,
              //     end: Alignment.bottomLeft,
              //     colors: [
              //       Colors.blue,
              //       Colors.red,
              //     ],
              //   ),
              // ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!_isEditable)
                        Container(
                          margin: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: Center(
                            child: Text(
                              '${profile.uFname} ${profile.uLname}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      if (!_pwdchng) _heading('User Profile'),
                      if (!_pwdchng) _detailsCard(),
                      if (_pwdchng)
                        ChangePassword(
                            profile.uLoginId, decoration, _togglePwdChange),
                      SizedBox(
                        height: 10,
                      ),
                      if (!_isEditable && !_pwdchng)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            elevation: 12,
                            primary: Colors.pink.shade300, // background
                            onPrimary: Colors.white, // foreground
                          ),
                          onPressed: _togglePwdChange,
                          icon: Icon(Icons.vpn_key),
                          label: _pwdchng
                              ? Text('Cancel')
                              : Text('Change Password'),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (_isEditable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    elevation: 12,
                                    primary: Colors.green, // background
                                    onPrimary: Colors.white,
                                    textStyle: TextStyle(fontSize: 18)),
                                label: Text('Update'),
                                icon: Icon(Icons.check_circle_outline),
                                onPressed: _submitUpdateProfileForm,
                              ),
                            ),
                            Flexible(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 12,
                                  primary: Colors.red, // background
                                  onPrimary: Colors.white, // foreground
                                  textStyle: TextStyle(fontSize: 18),
                                ),
                                icon: Icon(Icons.cancel_outlined),
                                label: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('Cancel'),
                                ),
                                onPressed: _toggleEdit,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            )),
    );
  }
}
